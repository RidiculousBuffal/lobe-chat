import { ModelProviderCard } from '@/types/llm';

const BingAI: ModelProviderCard = {
  chatModels: [
    {
      description: '更平衡的bingAI',
      enabled: true,
      functionCall: false,
      id: 'bing-Balanced',
      tokens: 128_000,
    },
    {
      description: '更准确的bingAI',
      enabled: true,
      functionCall: false,
      id: 'bing-Precise',
      tokens: 128_000,
    },
    {
      description: '更富有创造力的bingAI',
      enabled: true,
      functionCall: false,
      id: 'bing-Creative',
      tokens: 128_000,
    },
    {
      description: 'gpt4联网全能版本',
      enabled: true,
      functionCall: false,
      id: 'net-gpt-4-all',
      tokens: 128_000,
    },
    {
      description: 'gpt4o联网全能版本',
      enabled: true,
      functionCall: false,
      id: 'gpt-4o-all',
      tokens: 128_000,
    },
  ],
  checkModel: 'bing-Creative',
  id: 'bingai',
  modelList: { showModelFetcher: true },
  name: 'BingAI',
  proxyUrl: {
    placeholder: 'https://api.oneabc.org/v1',
  },
};
export default BingAI;
