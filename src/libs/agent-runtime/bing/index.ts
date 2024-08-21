import { ModelProvider } from '@/libs/agent-runtime/types';
import { LobeOpenAICompatibleFactory } from '@/libs/agent-runtime/utils/openaiCompatibleFactory';

export const LobeBingAI = LobeOpenAICompatibleFactory({
  baseURL: 'https://api.oneabc.org/v1',
  debug: {
    chatCompletion: () => process.env.DEBUG_BINGAI_CHAT_COMPLETION === '1',
  },
  provider: ModelProvider.Bingai,
});
