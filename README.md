# Proje Geliştirme Ortamı (.devcontainer)

Bu proje, Visual Studio Code'un Uzak Konteynerler (Remote - Containers) özelliği kullanılarak geliştirilmek üzere yapılandırılmıştır. `.devcontainer` klasörü, projenin tüm bağımlılıkları ve araçlarıyla birlikte tutarlı bir Docker konteyneri içinde çalışmasını sağlar.

## Yapılandırma Dosyaları ve İşlevleri

### 1. `devcontainer.json`

Bu dosya, VS Code'un geliştirme konteynerini nasıl yapılandıracağını ve yöneteceğini tanımlayan ana yapılandırma dosyasıdır.

*   **`name`**: Konteyner için bir isim tanımlar (örn: "react-app-component").
*   **`dockerComposeFile`**: Kullanılacak Docker Compose dosyalarını belirtir (örn: `./docker-compose.yml`).
*   **`service`**: Docker Compose dosyasında VS Code'un bağlanacağı servisin adını belirtir (örn: "react-dev").
*   **`customizations.vscode.extensions`**: Konteyner başlatıldığında otomatik olarak kurulacak VS Code eklentilerini listeler (örn: Prettier, ESLint).
*   **`customizations.vscode.settings`**: Konteyner içindeki VS Code için özel ayarları tanımlar (örn: terminal için varsayılan shell).
*   **`workspaceFolder`**: Konteyner içinde VS Code'un açacağı çalışma klasörünün yolunu belirtir (örn: "/workspace").
*   **`postCreateCommand`**: Konteyner oluşturulduktan sonra çalıştırılacak olan komut veya betiği belirtir (örn: `./.devcontainer/postcreate.sh`).

```json
// Örnek devcontainer.json içeriği
{
  "name": "react-app-component",
  "dockerComposeFile": [
    "./docker-compose.yml"
  ],
  "service": "react-dev",
  "customizations": {
    "vscode": {
      "extensions": [
        "esbenp.prettier-vscode",
        "dbaeumer.vscode-eslint",
        "ms-vscode.vscode-typescript-next",
        "github.vscode-pull-request-github"
      ],
      "settings": {
        "terminal.integrated.shell.linux": "/bin/bash"
      }
    }
  },
  "workspaceFolder": "/workspace",
  "postCreateCommand": "./.devcontainer/postcreate.sh"
}
```

### 2. `docker-compose.yml`

Bu dosya, geliştirme ortamını oluşturan Docker servislerini (konteynerlerini) ve ağlarını tanımlar.

*   **`networks`**: Proje için özel bir Docker ağı tanımlar.
*   **`services.react-dev`**: Geliştirme konteynerini tanımlar.
    *   **`container_name`**: Konteynere sabit bir isim verir.
    *   **`build.context`**: Dockerfile'ın bulunduğu dizini belirtir.
    *   **`build.dockerfile`**: Kullanılacak Dockerfile'ın adını belirtir.
    *   **`image`**: Oluşturulacak Docker imajının adını ve etiketini belirtir.
    *   **`networks`**: Konteynerin bağlanacağı ağı belirtir.
    *   **`volumes`**: Yerel dosya sistemini konteyner içine bağlar (proje dosyalarını `/workspace` içine).

```yaml
# Örnek docker-compose.yml içeriği
networks:
  react-component-devcontainer-network:
    name: react-component-devcontainer-network

services:
  react-dev:
    container_name: react-dev
    build:
      context: ./volumes/dockerfile
      dockerfile: Dockerfile
    image: telenity/rnd/react-devcontainer:monorepo
    networks:
      react-component-devcontainer-network: null
    volumes:
      - ..:/workspace
    # command: sleep infinity # Konteynerin sürekli çalışmasını sağlar
```

### 3. `volumes/dockerfile/Dockerfile`

Bu dosya, `react-dev` servisi için Docker imajının nasıl oluşturulacağını adım adım tanımlar.

*   **`FROM node:24-bookworm`**: Temel imaj olarak Node.js ve Debian Bookworm kullanır.
*   **`RUN apt-get update && apt-get install -y ...`**: Gerekli sistem bağımlılıklarını (git, build-essential vb.) kurar.
*   **`RUN npm install -g pnpm vite`**: pnpm ve Vite'ı global olarak kurar.
*   **`COPY ./bashrc.sh /tmp/bashrc.sh`**: `bashrc.sh` betiğini konteynere kopyalar.
*   **`RUN bash /tmp/bashrc.sh && rm /tmp/bashrc.sh`**: `bashrc.sh` betiğini çalıştırarak shell alias'larını ayarlar.
*   **`CMD ["sleep", "infinity"]`**: Konteyner başlatıldığında varsayılan olarak çalıştırılacak komutu belirtir, konteynerin sürekli çalışır durumda kalmasını sağlar.

### 4. `volumes/dockerfile/bashrc.sh`

Bu betik, Docker imajı oluşturulurken çalıştırılır ve konteyner içindeki Bash shell'i için kullanışlı kısayollar (alias'lar) tanımlar (`ll`, `la`, `ls` vb.).

### 5. `postcreate.sh`

Bu betik, konteyner oluşturulduktan sonra **bir kez** çalıştırılır ve projenin ilk kurulumunu yapar.

*   `pnpm-workspace.yaml` dosyasını oluşturarak monorepo yapısını tanımlar.
*   Kök dizinde `pnpm init` ile `package.json` oluşturur ve script'leri ayarlar.
*   `apps` ve `packages` dizinlerini oluşturur.
*   **`apps/comp1-app`**: Vite kullanarak bir React (TypeScript) test uygulaması oluşturur.
    *   `vite.config.ts` dosyasını port ve host ayarlarıyla yapılandırır.
    *   `App.tsx` dosyasını `comp1` paketindeki bileşeni kullanacak şekilde düzenler.
*   **`packages/comp1`**: Basit bir React bileşeni oluşturur.
    *   `pnpm init` ile `package.json` oluşturur.
    *   Gerekli geliştirme ve peer bağımlılıklarını (TypeScript, React) ekler.
    *   `tsconfig.json` dosyasını oluşturur.
    *   `src/index.tsx` içinde basit bir React bileşeni tanımlar.
    *   `package.json` dosyasındaki `main` ve `scripts` alanlarını günceller.
*   `comp1` paketini workspace kök `package.json` dosyasına bağımlılık olarak ekler.

## Geliştirme Ortamını Başlatma

1.  Docker'ın çalıştığından emin olun.
2.  VS Code'u açın.
3.  VS Code Command Palette (Cmd+Shift+P veya Ctrl+Shift+P) üzerinden "Remote-Containers: Reopen in Container" veya "Remote-Containers: Open Folder in Container..." komutunu çalıştırın.
4.  VS Code, `.devcontainer` yapılandırmasını kullanarak Docker imajını oluşturacak (eğer daha önce oluşturulmadıysa) ve konteyneri başlatacaktır.
5.  `postcreate.sh` betiği çalışarak proje yapısını ve ilk kurulumu tamamlayacaktır.
6.  Artık geliştirme ortamınız hazır!

## Kullanılabilir Komutlar (Kök Dizin `package.json`)

*   `pnpm run start:ui`: `comp1-app` uygulamasını geliştirme modunda başlatır (genellikle `http://localhost:3001` adresinde).
*   `pnpm run build:comp1`: `comp1` bileşenini derler.