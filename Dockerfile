# Dockerfile bazujący na obrazie używanym w etapie 'Staging E2E' z Jenkinsfile
FROM mcr.microsoft.com/playwright:v1.56.1-noble

# Instalacja globalnych narzędzi wymaganych przez pipeline Jenkins
RUN npm install -g netlify-cli@20.1.1 node-jq serve
RUN npm install -D @playwright/test@1.56.1

# # Ustaw katalog roboczy
# WORKDIR /app

# # Kopiuj pliki aplikacji (jeśli potrzebujesz budować obraz z kodem)
# COPY . .

# # Obraz nie wykonuje builda ani testów – te kroki pozostają w Jenkinsfile

# # Domyślna komenda (możesz nadpisać w pipeline)
# CMD ["node"]
