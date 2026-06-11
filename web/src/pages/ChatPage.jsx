import { useState, useRef, useEffect } from 'react';
import { chatWithAI } from '../services/api';
import { Send, Bot, User } from 'lucide-react';

export default function ChatPage() {
  const [messages, setMessages] = useState([
    {
      role: 'ai',
      content: "Hi there! 👋 I'm your AI wellness companion powered by Gemma. I'm here to listen, support, and offer insights. How are you feeling today?",
    },
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const bottomRef = useRef(null);

  useEffect(() => {
    bottomRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const sendMessage = async () => {
    const text = input.trim();
    if (!text || loading) return;

    setInput('');
    setMessages((prev) => [...prev, { role: 'user', content: text }]);
    setLoading(true);

    try {
      const data = await chatWithAI(text);
      setMessages((prev) => [...prev, { role: 'ai', content: data.reply }]);
    } catch {
      setMessages((prev) => [
        ...prev,
        { role: 'ai', content: "I'm having trouble connecting right now. Please try again in a moment." },
      ]);
    } finally {
      setLoading(false);
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  return (
    <>
      <div className="page-header">
        <h1>AI Chat 💬</h1>
        <p>Talk with your AI wellness companion — powered by Gemma</p>
      </div>

      <div className="chat-container">
        <div className="chat-messages">
          {messages.map((msg, i) => (
            <div key={i} className={`chat-message ${msg.role}`}>
              <div className="avatar">
                {msg.role === 'ai' ? <Bot size={18} color="white" /> : <User size={18} color="white" />}
              </div>
              <div className="bubble">{msg.content}</div>
            </div>
          ))}
          {loading && (
            <div className="chat-message ai">
              <div className="avatar">
                <Bot size={18} color="white" />
              </div>
              <div className="bubble" style={{ display: 'flex', gap: 4, alignItems: 'center' }}>
                <span className="typing-dot" style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--text-tertiary)', animation: 'pulse 1s ease-in-out infinite' }} />
                <span className="typing-dot" style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--text-tertiary)', animation: 'pulse 1s ease-in-out 0.2s infinite' }} />
                <span className="typing-dot" style={{ width: 6, height: 6, borderRadius: '50%', background: 'var(--text-tertiary)', animation: 'pulse 1s ease-in-out 0.4s infinite' }} />
              </div>
            </div>
          )}
          <div ref={bottomRef} />
        </div>

        <div className="chat-input-area">
          <input
            type="text"
            placeholder="Type your message..."
            value={input}
            onChange={(e) => setInput(e.target.value)}
            onKeyDown={handleKeyDown}
            disabled={loading}
          />
          <button className="chat-send-btn" onClick={sendMessage} disabled={loading || !input.trim()}>
            <Send size={18} />
          </button>
        </div>
      </div>

      <style>{`
        @keyframes pulse {
          0%, 100% { opacity: 0.3; transform: scale(0.8); }
          50% { opacity: 1; transform: scale(1.2); }
        }
      `}</style>
    </>
  );
}
