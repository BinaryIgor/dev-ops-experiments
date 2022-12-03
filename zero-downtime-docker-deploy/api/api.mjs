import http from "http"

const port = process.env.SERVER_PORT || 8080

const server = http.createServer((req, res) => {
    console.log("Some req...", req.url);

    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({
        timestamp: Date.now(),
        apiVersion: '1.0'
    }));
});

server.listen(port, () => console.log(`Server is running on ${port} port!`));

process.on('SIGINT', () => {
    console.log("Received stop signal, exiting...")
    process.exit();
});