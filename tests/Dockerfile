# Usa una imagen base limpia (ej. Ubuntu, Alpine, Debian)
FROM ubuntu:22.04

# Instala Git y cualquier otra dependencia necesaria para tu script
#RUN apt-get update && apt-get install -y curl vim tree nano

RUN apt-get install -y curl vim tree nano

RUN useradd -m rafiki
# 4. Copia tus dotfiles (idealmente aquí es donde los copias al home del nuevo user)
#    Nota: Si usas COPY ., los archivos pertenecerán inicialmente a root. 
#    Puedes usar --chown para asegurarte de que 'appuser' sea el dueño.
COPY --chown=rafiki:rafiki . /home/rafiki/dotfiles

# Copia tu repositorio de dotfiles al contenedor
#COPY . /home/rafiki/dotfiles

# 6. Define el usuario con el que se ejecutará el contenedor
USER rafiki

# Establece el directorio de trabajo
WORKDIR /home/rafiki/

# Ejecuta el script de instalación (asegúrate de que sea ejecutable)
#RUN ./install.sh

# Opcional: Define un comando por defecto para mantener el contenedor ejecutándose
CMD ["/bin/bash"]
