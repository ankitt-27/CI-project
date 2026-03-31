# ---------- Stage 1: Installer ----------
FROM node:20-bookworm AS installer

WORKDIR /juice-shop
COPY . .

# Install global tools
RUN npm i -g typescript ts-node

# Install production dependencies
RUN npm install --omit=dev --unsafe-perm
RUN npm dedupe --omit=dev

# Cleanup unnecessary frontend build artifacts
RUN rm -rf frontend/node_modules \
           frontend/.angular \
           frontend/src/assets

# Prepare runtime directories
RUN mkdir -p logs
RUN chown -R 65532 logs
RUN chgrp -R 0 ftp/ frontend/dist/ logs/ data/ i18n/ || true
RUN chmod -R g=u ftp/ frontend/dist/ logs/ data/ i18n/ || true

# Remove unnecessary files
RUN rm -f data/chatbot/botDefaultTrainingData.json \
          ftp/legal.md \
          i18n/*.json || true

# SBOM generation
ARG CYCLONEDX_NPM_VERSION=latest
RUN npm install -g @cyclonedx/cyclonedx-npm@$CYCLONEDX_NPM_VERSION
RUN npm run sbom


# ---------- Stage 2: Native module rebuild (libxmljs fix) ----------
FROM node:20-bookworm AS native-builder

WORKDIR /juice-shop

# Install ALL required native build dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      python3 \
      libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy node_modules from installer
COPY --from=installer /juice-shop/node_modules ./node_modules

# Force clean rebuild of libxmljs
RUN npm rebuild libxmljs --build-from-source


# ---------- Stage 3: Final runtime ----------
FROM gcr.io/distroless/nodejs20-debian11

ARG BUILD_DATE
ARG VCS_REF

LABEL maintainer="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.title="OWASP Juice Shop" \
    org.opencontainers.image.description="Probably the most modern and sophisticated insecure web application" \
    org.opencontainers.image.authors="Bjoern Kimminich <bjoern.kimminich@owasp.org>" \
    org.opencontainers.image.vendor="Open Worldwide Application Security Project" \
    org.opencontainers.image.documentation="https://help.owasp-juice.shop" \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.version="17.1.0" \
    org.opencontainers.image.url="https://owasp-juice.shop" \
    org.opencontainers.image.source="https://github.com/juice-shop/juice-shop" \
    org.opencontainers.image.revision=$VCS_REF \
    org.opencontainers.image.created=$BUILD_DATE

WORKDIR /juice-shop

# Copy full app
COPY --from=installer --chown=65532:0 /juice-shop .

# Overwrite with rebuilt native module
COPY --from=native-builder --chown=65532:0 \
    /juice-shop/node_modules/libxmljs \
    ./node_modules/libxmljs

# Run as non-root
USER 65532

EXPOSE 3000

CMD ["/juice-shop/build/app.js"]
