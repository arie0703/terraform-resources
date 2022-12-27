docker build -t apache_page ./
docker run -p 8080:80 --name apache_page -d -it --rm apache_page bash
# docker start apache_page
curl localhost:8080
