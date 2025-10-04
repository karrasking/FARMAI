import { useState } from 'react'
import { X, Minimize2, Maximize2, Send, Bot, User, Sparkles } from 'lucide-react'
import { Button } from './ui/button'
import { ChatMessageList } from './ui/chat-message-list'

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

interface FloatingChatProps {
  isOpen: boolean
  onClose: () => void
}

function AssistantMessage({ content }: { content: string }) {
  return (
    <div className="flex gap-2 items-start">
      <div className="w-6 h-6 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
        <Bot className="w-4 h-4 text-white" />
      </div>
      <div className="flex-1 bg-blue-50 rounded-lg p-2 border border-blue-100">
        <p className="text-xs text-gray-800">{content}</p>
      </div>
    </div>
  )
}

function UserMessage({ content }: { content: string }) {
  return (
    <div className="flex gap-2 items-start justify-end">
      <div className="flex-1 bg-gray-100 rounded-lg p-2 border border-gray-200 text-right">
        <p className="text-xs text-gray-800">{content}</p>
      </div>
      <div className="w-6 h-6 rounded-full bg-gray-600 flex items-center justify-center flex-shrink-0">
        <User className="w-4 h-4 text-white" />
      </div>
    </div>
  )
}

export function FloatingChat({ isOpen, onClose }: FloatingChatProps) {
  const [messages, setMessages] = useState<Message[]>([
    {
      id: '1',
      role: 'assistant',
      content: '¡Hola! Soy el asistente de FARMAI. ¿En qué puedo ayudarte?',
      timestamp: new Date(),
    },
  ])
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)
  const [isMinimized, setIsMinimized] = useState(false)

  const handleSend = async () => {
    if (!input.trim()) return

    const userMessage: Message = {
      id: Date.now().toString(),
      role: 'user',
      content: input,
      timestamp: new Date(),
    }

    setMessages([...messages, userMessage])
    setInput('')
    setIsLoading(true)

    // Simular respuesta
    setTimeout(() => {
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: `Entiendo tu consulta sobre "${input}". Estoy en modo demostración. Una vez conectado a la BD, podré consultar los 20,271 medicamentos en tiempo real.`,
        timestamp: new Date(),
      }
      setMessages((prev) => [...prev, assistantMessage])
      setIsLoading(false)
    }, 1000)
  }

  const handleMinimize = () => {
    setIsMinimized(!isMinimized)
  }

  if (!isOpen) return null

  return (
    <div className="fixed bottom-6 right-6 z-50">
      <div
        className={`bg-white rounded-lg shadow-2xl border border-gray-200 transition-all duration-300 ${
          isMinimized ? 'w-80 h-14' : 'w-96 h-[600px]'
        }`}
      >
        {/* Header */}
        <div className="bg-gradient-to-r from-blue-600 to-blue-700 text-white px-4 py-3 rounded-t-lg flex items-center justify-between">
          <div className="flex items-center gap-2">
            <Sparkles className="w-5 h-5" />
            <div>
              <h3 className="font-semibold text-sm">Chat FARMAI</h3>
              <p className="text-xs opacity-90">Asistente IA</p>
            </div>
          </div>
          <div className="flex items-center gap-1">
            <button
              onClick={handleMinimize}
              className="p-1 hover:bg-white/20 rounded transition-colors"
              title={isMinimized ? 'Maximizar' : 'Minimizar'}
            >
              {isMinimized ? (
                <Maximize2 className="w-4 h-4" />
              ) : (
                <Minimize2 className="w-4 h-4" />
              )}
            </button>
            <button
              onClick={onClose}
              className="p-1 hover:bg-white/20 rounded transition-colors"
              title="Cerrar"
            >
              <X className="w-4 h-4" />
            </button>
          </div>
        </div>

        {/* Body */}
        {!isMinimized && (
          <>
            {/* Messages */}
            <div className="h-[480px] overflow-hidden bg-gray-50">
              <ChatMessageList>
                {messages.map((message) =>
                  message.role === 'assistant' ? (
                    <AssistantMessage key={message.id} content={message.content} />
                  ) : (
                    <UserMessage key={message.id} content={message.content} />
                  )
                )}
                {isLoading && (
                  <div className="flex gap-2 items-start">
                    <div className="w-6 h-6 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
                      <Bot className="w-4 h-4 text-white" />
                    </div>
                    <div className="flex-1 bg-blue-50 rounded-lg p-2 border border-blue-100">
                      <div className="flex items-center gap-1">
                        <div className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce" />
                        <div
                          className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce"
                          style={{ animationDelay: '0.2s' }}
                        />
                        <div
                          className="w-1.5 h-1.5 bg-blue-600 rounded-full animate-bounce"
                          style={{ animationDelay: '0.4s' }}
                        />
                      </div>
                    </div>
                  </div>
                )}
              </ChatMessageList>
            </div>

            {/* Input */}
            <div className="border-t p-3 bg-white rounded-b-lg">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Escribe tu pregunta..."
                  className="flex-1 px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <Button
                  onClick={handleSend}
                  disabled={!input.trim() || isLoading}
                  size="sm"
                  className="px-3"
                >
                  <Send className="w-4 h-4" />
                </Button>
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  )
}
