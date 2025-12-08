# Usa una imagen base limpia (ej. Ubuntu, Alpine, Debian)
FROM ubuntu:22.04

# Actualiza repos e instala herramientas necesarias
RUN apt-get update && apt-get install -y curl vim tree nano passwd sudo

# Crear usuario 'rafiki' con home
RUN useradd -m rafiki
RUN usermod -aG sudo rafiki

# Configurar password 'test' para el usuario 'rafiki'
RUN echo "rafiki:test" | chpasswd
RUN echo "root:test" | chpasswd

# Copia los dotfiles con el owner correcto
COPY --chown=rafiki:rafiki . /home/rafiki/dotfiles

# Define el usuario con el que se ejecutará el contenedor
USER rafiki

# Establece el directorio de trabajo
WORKDIR /home/rafiki/

# Comando por defecto
CMD ["/bin/bash"]
