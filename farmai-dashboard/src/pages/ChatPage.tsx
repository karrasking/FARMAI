import { useState } from 'react'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Button } from '@/components/ui/button'
import { Send, Sparkles, Bot, User } from 'lucide-react'
import { ChatMessageList } from '@/components/ui/chat-message-list'

interface Message {
  id: string
  role: 'user' | 'assistant'
  content: string
  timestamp: Date
}

// Mock messages
const initialMessages: Message[] = [
  {
    id: '1',
    role: 'assistant',
    content: '¡Hola! Soy el asistente de FARMAI. Puedo ayudarte a consultar información sobre medicamentos, interacciones, principios activos y mucho más. ¿En qué puedo ayudarte?',
    timestamp: new Date(Date.now() - 60000),
  },
]

// Message Components
function AssistantMessage({ content }: { content: string }) {
  return (
    <div className="flex gap-3 items-start">
      <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
        <Bot className="w-5 h-5 text-white" />
      </div>
      <div className="flex-1 bg-blue-50 rounded-lg p-3 border border-blue-100">
        <p className="text-sm text-gray-800">{content}</p>
      </div>
    </div>
  )
}

function UserMessage({ content }: { content: string }) {
  return (
    <div className="flex gap-3 items-start justify-end">
      <div className="flex-1 bg-gray-100 rounded-lg p-3 border border-gray-200 text-right">
        <p className="text-sm text-gray-800">{content}</p>
      </div>
      <div className="w-8 h-8 rounded-full bg-gray-600 flex items-center justify-center flex-shrink-0">
        <User className="w-5 h-5 text-white" />
      </div>
    </div>
  )
}

const suggestedQuestions = [
  '¿Cuántos medicamentos con ibuprofeno hay disponibles?',
  'Muéstrame información sobre interacciones medicamentosas',
  '¿Qué medicamentos son EFG (genéricos)?',
  'Busca alertas geriátricas para medicamentos',
  'Información sobre biomarcadores farmacogenéticos',
]

export function ChatPage() {
  const [messages, setMessages] = useState(initialMessages)
  const [input, setInput] = useState('')
  const [isLoading, setIsLoading] = useState(false)

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

    // Simular respuesta del asistente
    setTimeout(() => {
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: 'assistant',
        content: `Entiendo tu consulta sobre "${input}". En este momento estoy en modo demostración y no estoy conectado a la base de datos. Una vez conectado, podré consultar información en tiempo real sobre los 20,271 medicamentos, 29,540 presentaciones y todas las relaciones del grafo de conocimiento FARMAI.`,
        timestamp: new Date(),
      }
      setMessages((prev) => [...prev, assistantMessage])
      setIsLoading(false)
    }, 1000)
  }

  const handleSuggestion = (question: string) => {
    setInput(question)
  }

  return (
    <div className="h-[calc(100vh-8rem)] flex flex-col">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-3xl font-bold text-gray-900 flex items-center gap-2">
          <Sparkles className="w-8 h-8 text-blue-600" />
          Chat Inteligente FARMAI
        </h1>
        <p className="text-gray-500 mt-1">Consulta la base de datos en lenguaje natural</p>
      </div>

      <div className="flex-1 flex gap-6">
        {/* Chat Area */}
        <Card className="flex-1 flex flex-col">
          <CardHeader>
            <CardTitle>Conversación</CardTitle>
            <CardDescription>
              Pregunta lo que necesites sobre medicamentos, interacciones y más
            </CardDescription>
          </CardHeader>
          <CardContent className="flex-1 flex flex-col p-0">
            {/* Messages */}
            <div className="flex-1 overflow-hidden">
              <ChatMessageList>
                {messages.map((message) => (
                  message.role === 'assistant' ? (
                    <AssistantMessage key={message.id} content={message.content} />
                  ) : (
                    <UserMessage key={message.id} content={message.content} />
                  )
                ))}
                {isLoading && (
                  <div className="flex gap-3 items-start">
                    <div className="w-8 h-8 rounded-full bg-blue-600 flex items-center justify-center flex-shrink-0">
                      <Bot className="w-5 h-5 text-white" />
                    </div>
                    <div className="flex-1 bg-blue-50 rounded-lg p-3 border border-blue-100">
                      <div className="flex items-center gap-2 text-gray-500">
                        <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" />
                        <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.2s' }} />
                        <div className="w-2 h-2 bg-blue-600 rounded-full animate-bounce" style={{ animationDelay: '0.4s' }} />
                        <span className="ml-2 text-sm">Pensando...</span>
                      </div>
                    </div>
                  </div>
                )}
              </ChatMessageList>
            </div>

            {/* Input Area */}
            <div className="border-t p-4">
              <div className="flex gap-2">
                <input
                  type="text"
                  value={input}
                  onChange={(e) => setInput(e.target.value)}
                  onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                  placeholder="Escribe tu pregunta aquí..."
                  className="flex-1 px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                />
                <Button onClick={handleSend} disabled={!input.trim() || isLoading}>
                  <Send className="w-4 h-4 mr-2" />
                  Enviar
                </Button>
              </div>
            </div>
          </CardContent>
        </Card>

        {/* Suggestions Sidebar */}
        <Card className="w-80">
          <CardHeader>
            <CardTitle className="text-lg">Preguntas Sugeridas</CardTitle>
            <CardDescription>Haz clic para preguntar</CardDescription>
          </CardHeader>
          <CardContent>
            <div className="space-y-2">
              {suggestedQuestions.map((question, index) => (
                <button
                  key={index}
                  onClick={() => handleSuggestion(question)}
                  className="w-full text-left p-3 text-sm bg-gray-50 hover:bg-gray-100 rounded-lg transition-colors border border-gray-200"
                >
                  {question}
                </button>
              ))}
            </div>

            <div className="mt-6 pt-6 border-t">
              <h3 className="font-semibold text-sm mb-2">💡 Capacidades</h3>
              <ul className="text-xs text-gray-600 space-y-1">
                <li>• Búsqueda de medicamentos</li>
                <li>• Consulta de interacciones</li>
                <li>• Información de principios activos</li>
                <li>• Alertas de seguridad</li>
                <li>• Farmacogenómica</li>
                <li>• Y mucho más...</li>
              </ul>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
