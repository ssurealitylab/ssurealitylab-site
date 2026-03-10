#!/usr/bin/env python3
"""
Reality Lab AI Chatbot Server
Flask-based server with hierarchical RAG and llama-server integration
"""

import os
import sys
import json
import re
import argparse
import threading
import time
import gc
from datetime import datetime

import pytz
import requests
from flask import Flask, request, jsonify, Response, stream_with_context
from flask_cors import CORS

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from hierarchical_retriever import HierarchicalRetriever

app = Flask(__name__)
CORS(app)

# Global variables
rag_retriever = None
request_lock = threading.Lock()
KST = pytz.timezone('Asia/Seoul')

# Configuration
LLAMA_SERVER_URL = "http://localhost:8081"
RAG_DIR = "/home/i0179/Realitylab-site/ai_server/hierarchical_rag"

# System prompt
SYSTEM_PROMPT_KO = """당신은 숭실대학교 Reality Lab(리얼리티 연구실)의 AI 어시스턴트입니다.
연구실의 정보, 구성원, 연구 분야, 논문 등에 대한 질문에 친절하고 정확하게 답변해주세요.
제공된 참고자료를 기반으로 답변하되, 참고자료에 없는 내용은 "정확한 정보를 찾지 못했습니다"라고 말씀해주세요.
답변은 한국어로 해주세요."""

SYSTEM_PROMPT_EN = """You are an AI assistant for Reality Lab at Soongsil University.
Answer questions about the lab's information, members, research areas, and publications accurately and helpfully.
Base your answers on the provided reference materials. If information is not available, say so.
Answer in English."""


def is_rest_time():
    """Check if current time is during rest hours (04:00-08:00 KST)"""
    now = datetime.now(KST)
    return 4 <= now.hour < 8


def load_rag():
    """Load hierarchical RAG retriever"""
    global rag_retriever
    try:
        print("Loading hierarchical RAG...")
        rag_retriever = HierarchicalRetriever(RAG_DIR)
        rag_retriever.load()
        print("RAG loaded successfully!")
    except Exception as e:
        print(f"Warning: Failed to load RAG: {e}")
        rag_retriever = None


def detect_language(text):
    """Detect if text is Korean or English"""
    korean_chars = sum(1 for c in text if '\uac00' <= c <= '\ud7a3' or '\u3131' <= c <= '\u3163')
    return 'ko' if korean_chars > len(text) * 0.1 else 'en'


def get_rag_context(question, language='ko'):
    """Get RAG context for a question"""
    if rag_retriever is None:
        return ""

    try:
        results = rag_retriever.search(question, k=5, min_score=0.3)
        if results:
            return rag_retriever.format_context(results, language=language)
    except Exception as e:
        print(f"RAG search error: {e}")

    return ""


def call_llama_server(question, context="", language="ko"):
    """Call llama-server (GPT-OSS-120B) for generating responses"""
    system_prompt = SYSTEM_PROMPT_KO if language == 'ko' else SYSTEM_PROMPT_EN

    if context:
        user_message = f"{context}\n\n질문: {question}" if language == 'ko' else f"{context}\n\nQuestion: {question}"
    else:
        user_message = question

    payload = {
        "model": "gpt-oss-120b",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message}
        ],
        "temperature": 0.7,
        "max_tokens": 1024,
        "stream": False
    }

    try:
        response = requests.post(
            f"{LLAMA_SERVER_URL}/v1/chat/completions",
            json=payload,
            timeout=120
        )
        response.raise_for_status()
        data = response.json()
        return data['choices'][0]['message']['content']
    except requests.exceptions.ConnectionError:
        return None
    except Exception as e:
        print(f"llama-server error: {e}")
        return None


def call_llama_server_stream(question, context="", language="ko"):
    """Call llama-server with streaming"""
    system_prompt = SYSTEM_PROMPT_KO if language == 'ko' else SYSTEM_PROMPT_EN

    if context:
        user_message = f"{context}\n\n질문: {question}" if language == 'ko' else f"{context}\n\nQuestion: {question}"
    else:
        user_message = question

    payload = {
        "model": "gpt-oss-120b",
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_message}
        ],
        "temperature": 0.7,
        "max_tokens": 1024,
        "stream": True
    }

    try:
        response = requests.post(
            f"{LLAMA_SERVER_URL}/v1/chat/completions",
            json=payload,
            timeout=120,
            stream=True
        )
        response.raise_for_status()

        for line in response.iter_lines():
            if line:
                line_str = line.decode('utf-8')
                if line_str.startswith('data: '):
                    data_str = line_str[6:]
                    if data_str.strip() == '[DONE]':
                        break
                    try:
                        data = json.loads(data_str)
                        delta = data.get('choices', [{}])[0].get('delta', {})
                        content = delta.get('content', '')
                        if content:
                            yield content
                    except json.JSONDecodeError:
                        continue
    except Exception as e:
        print(f"llama-server stream error: {e}")
        yield f"Error: {e}"


@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    # Check llama-server status
    llama_status = "unknown"
    try:
        resp = requests.get(f"{LLAMA_SERVER_URL}/health", timeout=5)
        if resp.status_code == 200:
            llama_status = "healthy"
        else:
            llama_status = "unhealthy"
    except:
        llama_status = "unreachable"

    return jsonify({
        "status": "healthy",
        "rag_loaded": rag_retriever is not None,
        "llama_server": llama_status,
        "rest_time": is_rest_time()
    })


@app.route('/chat', methods=['POST'])
def chat():
    """Main chat endpoint"""
    if is_rest_time():
        return jsonify({
            "response": "💤 AI 쉬는시간입니다 (04:00-08:00 KST). 잠시 후 다시 시도해주세요!",
            "status": "rest_time"
        })

    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON data provided"}), 400

    question = data.get('question', '').strip()
    if not question:
        return jsonify({"error": "No question provided"}), 400

    mode = data.get('mode', 'deep')  # deep, fast, search
    language = detect_language(question)

    print(f"\n[Chat] Mode: {mode}, Language: {language}")
    print(f"[Chat] Question: {question}")

    with request_lock:
        # Get RAG context
        context = get_rag_context(question, language)
        if context:
            print(f"[RAG] Found context ({len(context)} chars)")

        if mode == 'search':
            # Search mode - return RAG results only
            if context:
                return jsonify({
                    "response": context,
                    "status": "success",
                    "mode": "search"
                })
            else:
                msg = "관련 정보를 찾지 못했습니다." if language == 'ko' else "No relevant information found."
                return jsonify({
                    "response": msg,
                    "status": "no_results",
                    "mode": "search"
                })

        # Deep mode (default) - use llama-server
        response_text = call_llama_server(question, context, language)

        if response_text:
            return jsonify({
                "response": response_text,
                "status": "success",
                "mode": mode
            })
        else:
            # llama-server is down - return error
            return jsonify({
                "error": "AI 서버에 연결할 수 없습니다." if language == 'ko' else "Cannot connect to AI server.",
                "status": "error"
            }), 503


@app.route('/chat/stream', methods=['POST'])
def chat_stream():
    """Streaming chat endpoint"""
    if is_rest_time():
        def rest_response():
            yield f"data: {json.dumps({'content': '💤 AI 쉬는시간입니다 (04:00-08:00 KST).'})}\n\n"
            yield "data: [DONE]\n\n"
        return Response(rest_response(), mimetype='text/event-stream')

    data = request.get_json()
    if not data:
        return jsonify({"error": "No JSON data provided"}), 400

    question = data.get('question', '').strip()
    if not question:
        return jsonify({"error": "No question provided"}), 400

    language = detect_language(question)
    context = get_rag_context(question, language)

    def generate():
        try:
            for chunk in call_llama_server_stream(question, context, language):
                yield f"data: {json.dumps({'content': chunk})}\n\n"
            yield "data: [DONE]\n\n"
        except Exception as e:
            yield f"data: {json.dumps({'error': str(e)})}\n\n"
            yield "data: [DONE]\n\n"

    return Response(stream_with_context(generate()), mimetype='text/event-stream')


def main():
    parser = argparse.ArgumentParser(description='Reality Lab AI Chatbot Server')
    parser.add_argument('--port', type=int, default=4005, help='Server port')
    parser.add_argument('--host', type=str, default='0.0.0.0', help='Server host')
    args = parser.parse_args()

    # Load RAG
    load_rag()

    print(f"\nStarting chatbot server on {args.host}:{args.port}")
    app.run(host=args.host, port=args.port, debug=False, threaded=True)


if __name__ == "__main__":
    main()
