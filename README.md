# Nagios Core en Docker

## Construcción local

1. Clonar el repositorio y entrar al directorio:

```bash
git clone https://github.com/manriquz/nagios-docker.git
cd nagios-docker
```

2. Construir la imagen Docker:

```bash
docker build -t nagios-core .
```

3. Ejecutar el contenedor:

```bash
docker run -d -p 8080:80 --name nagios nagios-core
```

4. Acceder vía navegador:

```
http://localhost:8080
```

- Usuario: `nagiosadmin`
- Contraseña: `nagiosadmin`

Este contenedor fue preparado por cmanriquez para pruebas locales de Nagios Core.
