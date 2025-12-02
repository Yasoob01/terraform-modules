#!/bin/bash
cat > index.html <<EOF 
<html>
    <body>
        <h1>Hello, World!</h1>
        <p>This is a test instance. On Port: ${server_port}</p>
        <p>Database Address: ${db_instance_address}</p>
        <p>Database Port: ${db_instance_port}</p>
    </body>
</html>
EOF

nohup busybox httpd -f -p ${server_port} &

