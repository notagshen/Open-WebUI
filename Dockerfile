FROM ghcr.io/open-webui/open-webui:main
RUN touch .webui_secret_key && chmod 644 .webui_secret_key
