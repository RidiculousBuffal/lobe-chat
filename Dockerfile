## Base image for all the stages
FROM node:20-alpine AS base
ARG APP_URL="https://cathaybot.zeabur.app"
ARG USE_CN_MIRROR
ARG NEXT_PUBLIC_S3_DOMAIN="https://hpcow-1316827225.cos.ap-shanghai.myqcloud.com"
RUN \
    # If you want to build docker in China, build with --build-arg USE_CN_MIRROR=true
    if [ "${USE_CN_MIRROR:-false}" = "true" ]; then \
        sed -i "s/dl-cdn.alpinelinux.org/mirrors.ustc.edu.cn/g" "/etc/apk/repositories"; \
    fi \
    # Add required package & update base package
    && apk update \
    && apk add --no-cache bind-tools proxychains-ng \
    && apk upgrade --no-cache \
    # Add user nextjs to run the app
    && addgroup --system --gid 1001 nodejs \
    && adduser --system --uid 1001 nextjs \
    && chown -R nextjs:nodejs "/etc/proxychains" \
    && rm -rf /tmp/* /var/cache/apk/*

## Builder image, install all the dependencies and build the app
FROM base AS builder

ARG USE_CN_MIRROR

ENV NEXT_PUBLIC_SERVICE_MODE="server" \
    APP_URL=${APP_URL} \
    DATABASE_DRIVER="node" \
    DATABASE_URL="postgresql://root:nBv2W84zOiw1p7AXoLyS5lDH0x39chY6@sfo1.clusters.zeabur.com:32198/zeabur" \
    KEY_VAULTS_SECRET="use-for-build"

# Sentry
ENV NEXT_PUBLIC_SENTRY_DSN="" \
    SENTRY_ORG="" \
    SENTRY_PROJECT=""

# Posthog
ENV NEXT_PUBLIC_ANALYTICS_POSTHOG="" \
    NEXT_PUBLIC_POSTHOG_HOST="" \
    NEXT_PUBLIC_POSTHOG_KEY=""

# Umami
ENV NEXT_PUBLIC_ANALYTICS_UMAMI="" \
    NEXT_PUBLIC_UMAMI_SCRIPT_URL="" \
    NEXT_PUBLIC_UMAMI_WEBSITE_ID=""

# Node
ENV NODE_OPTIONS="--max-old-space-size=8192"

WORKDIR /app

COPY package.json ./
COPY .npmrc ./

RUN \
    # If you want to build docker in China, build with --build-arg USE_CN_MIRROR=true
    if [ "${USE_CN_MIRROR:-false}" = "true" ]; then \
        export SENTRYCLI_CDNURL="https://npmmirror.com/mirrors/sentry-cli"; \
        npm config set registry "https://registry.npmmirror.com/"; \
    fi \
    # Set the registry for corepack
    && export COREPACK_NPM_REGISTRY=$(npm config get registry | sed 's/\/$//') \
    # Enable corepack
    && corepack enable \
    # Use pnpm for corepack
    && corepack use pnpm \
    # Install the dependencies
    && pnpm i \
    # Add sharp and db migration dependencies
    && mkdir -p /deps \
    && pnpm add sharp pg drizzle-orm --prefix /deps

COPY . .

# run build standalone for docker version
RUN npm run build:docker

## Application image, copy all the files for production
FROM scratch AS app

COPY --from=builder /app/public /app/public

# Automatically leverage output traces to reduce image size
# https://nextjs.org/docs/advanced-features/output-file-tracing
COPY --from=builder /app/.next/standalone /app/
COPY --from=builder /app/.next/static /app/.next/static

# copy dependencies
COPY --from=builder /deps/node_modules/.pnpm /app/node_modules/.pnpm
COPY --from=builder /deps/node_modules/pg /app/node_modules/pg
COPY --from=builder /deps/node_modules/drizzle-orm /app/node_modules/drizzle-orm

# Copy database migrations
COPY --from=builder /app/src/database/server/migrations /app/migrations
COPY --from=builder /app/scripts/migrateServerDB/docker.cjs /app/docker.cjs
COPY --from=builder /app/scripts/migrateServerDB/errorHint.js /app/errorHint.js

## Production image, copy all the files and run next
FROM base

# Copy all the files from app, set the correct permission for prerender cache
COPY --from=app --chown=nextjs:nodejs /app /app

ENV NODE_ENV="production"

# set hostname to localhost
ENV HOSTNAME="0.0.0.0" \
    PORT="3210"

# General Variables
ENV ACCESS_CODE="Cathay123456" \
    APP_URL=${APP_URL} \
    API_KEY_SELECT_MODE="" \
    DEFAULT_AGENT_CONFIG="" \
    SYSTEM_AGENT="" \
    FEATURE_FLAGS="" \
    PROXY_URL=""

# Database
ENV KEY_VAULTS_SECRET="+HhuXdu0C5NhMcYNIOxf91kJPHZKvzZnryy9lwvMnBE=" \
    DATABASE_DRIVER="node" \
    DATABASE_URL="postgresql://root:nBv2W84zOiw1p7AXoLyS5lDH0x39chY6@sfo1.clusters.zeabur.com:32198/zeabur"

# Next Auth
ENV NEXT_AUTH_SECRET="+HhuXdu0C5NhMcYNIOxf91kJPHZKvzZnryy9lwvMnBE=" \
NEXTAUTH_URL="https://cathaybot.zeabur.app/api/auth" \
NEXT_AUTH_SSO_PROVIDERS="azure-ad,auth0" \
AZURE_AD_CLIENT_ID="b315490a-0e57-4f66-b6ea-6c980bdf8907" \
AZURE_AD_CLIENT_SECRET="Z318Q~X83TYmXEXy~OjgPGEZao5OK3qZfYshKb2X" \
AZURE_AD_TENANT_ID="52fc6378-ecb3-42d1-b528-6111ae133fc1" \
AUTH0_CLIENT_ID="x2TAhrOpb9iEe7OqWQsaM9oNzZ63dNHQ" \
AUTH0_CLIENT_SECRET="WzsSkh26QKJj0G-or9vxvDGwHd4DjKzIXlzxpIgL6_mf8_qaopFscFXZFWzKzcjE" \
AUTH0_ISSUER="https://dev-itiifj0yxxduxhom.us.auth0.com" \
ACCESS_CODE="Cathay123456"

# S3
ENV S3_ACCESS_KEY_ID="AKIDhJ1qeVQcsoopsqsrmdPJCyeNC84wlhku" \
    S3_SECRET_ACCESS_KEY="AQemXC2qYCoT8sY2IMH3cxEKYdgbK0Yz" \
    NEXT_PUBLIC_S3_DOMAIN=${NEXT_PUBLIC_S3_DOMAIN} \
    S3_ENDPOINT="https://cos.ap-shanghai.myqcloud.com" \
    S3_BUCKET="hpcow-1316827225" \
    ACCESS_CODE="Cathay123456" \
    S3_PUBLIC_DOMAIN=${NEXT_PUBLIC_S3_DOMAIN}


# unstructured IO

ENV  UNSTRUCTURED_API_KEY="cHSLrbZzLKOihkgi4DUvsDIBsrsL0F" \
     UNSTRUCTURED_SERVER_URL="https://api.unstructuredapp.io/general/v0/general"


# Model Variables
ENV \
    # Ai360
    AI360_API_KEY="" \
    # Anthropic
    ANTHROPIC_API_KEY="" ANTHROPIC_PROXY_URL="" \
    # Amazon Bedrock
    AWS_ACCESS_KEY_ID="" AWS_SECRET_ACCESS_KEY="" AWS_REGION="" \
    # Azure OpenAI
    AZURE_API_KEY="876571fe014c4230947dfb743314ee8e" AZURE_API_VERSION="2024-05-01-preview" AZURE_ENDPOINT="https://cathaywestus.openai.azure.com" AZURE_MODEL_LIST="gpt-35-turbo->gpt-35-turbo=gpt-35-turbo" \
    # Baichuan
    BAICHUAN_API_KEY="" \
    # DeepSeek
    DEEPSEEK_API_KEY="" \
    # Google
    GOOGLE_API_KEY="" GOOGLE_PROXY_URL="" \
    # Groq
    GROQ_API_KEY="" GROQ_PROXY_URL="" \
    # Minimax
    MINIMAX_API_KEY="" \
    # Mistral
    MISTRAL_API_KEY="" \
    # Moonshot
    MOONSHOT_API_KEY="" MOONSHOT_PROXY_URL="" \
    # Novita
    NOVITA_API_KEY="" NOVITA_MODEL_LIST="" \
    # Ollama
    OLLAMA_MODEL_LIST="" OLLAMA_PROXY_URL="" \
    # OpenAI
    OPENAI_API_KEY="sk-6O3WQK3NVhv2Dec4F4B7026eA28443C4906b3cC0A2CbE0Fe" OPENAI_MODEL_LIST="+gpt-4o=gpt-4o<1280000:fc:vision>,+gpt-4o-mini=<1280000:fc:vision>,+gpt-4-turbo-2024-04-09=<1280000:fc:vision>,gpt-4-all=ChatGPT Plus<128000:fc:vision:file>" OPENAI_PROXY_URL="https://aihubmix.com/v1" \
    # OpenRouter
    OPENROUTER_API_KEY="" OPENROUTER_MODEL_LIST="" \
    # Perplexity
    PERPLEXITY_API_KEY="" PERPLEXITY_PROXY_URL="" \
    # Qwen
    QWEN_API_KEY="" QWEN_MODEL_LIST="" \
    # SiliconCloud
    SILICONCLOUD_API_KEY="" SILICONCLOUD_MODEL_LIST="" SILICONCLOUD_PROXY_URL="" \
    # Stepfun
    STEPFUN_API_KEY="" \
    # Taichu
    TAICHU_API_KEY="" \
    # TogetherAI
    TOGETHERAI_API_KEY="" TOGETHERAI_MODEL_LIST="" \
    # Upstage
    UPSTAGE_API_KEY="" \
    # 01.AI
    ZEROONE_API_KEY="" ZEROONE_MODEL_LIST="" \
    # Zhipu
    ZHIPU_API_KEY="" \
    #Bingai
    BINGAI_API_KEY="sk-sxs1OsIBdzH8OqgdDc03C8D8E15545E58f002b09747b0645" BINGAI_PROXY_URL="https://api.oneabc.org/v1"

USER nextjs

EXPOSE 3210/tcp

CMD \
    if [ -n "$PROXY_URL" ]; then \
        # Set regex for IPv4
        IP_REGEX="^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$"; \
        # Set proxychains command
        PROXYCHAINS="proxychains -q"; \
        # Parse the proxy URL
        host_with_port="${PROXY_URL#*//}"; \
        host="${host_with_port%%:*}"; \
        port="${PROXY_URL##*:}"; \
        protocol="${PROXY_URL%%://*}"; \
        # Resolve to IP address if the host is a domain
        if ! [[ "$host" =~ "$IP_REGEX" ]]; then \
            nslookup=$(nslookup -q="A" "$host" | tail -n +3 | grep 'Address:'); \
            if [ -n "$nslookup" ]; then \
                host=$(echo "$nslookup" | tail -n 1 | awk '{print $2}'); \
            fi; \
        fi; \
        # Generate proxychains configuration file
        printf "%s\n" \
            'localnet 127.0.0.0/255.0.0.0' \
            'localnet ::1/128' \
            'proxy_dns' \
            'remote_dns_subnet 224' \
            'strict_chain' \
            'tcp_connect_time_out 8000' \
            'tcp_read_time_out 15000' \
            '[ProxyList]' \
            "$protocol $host $port" \
        > "/etc/proxychains/proxychains.conf"; \
    fi; \
    # Run migration
    node "/app/docker.cjs"; \
    if [ "$?" -eq "0" ]; then \
      # Run the server
      ${PROXYCHAINS} node "/app/server.js"; \
    fi;
