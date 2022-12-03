import http from "http"

const port = process.env.SERVER_PORT || 8080

const server = http.createServer((req, res) => {
    console.log("Some req...", req.url);

    res.statusCode = 200;
    res.setHeader('Content-Type', 'application/json');
    res.end(JSON.stringify({
        timestamp: Date.now(),
        apiVersion: '1.1'
    }));
});

setTimeout(() => server.listen(port, () => console.log(`Server is running on ${port} port!`)), 1000);

process.on('SIGTERM', () => {
    console.log("Received SIGTERM signal, exiting...")
    process.exit();
});

process.on('SIGINT', () => {
    console.log("Received SIGINT signal, exiting...")
    process.exit();
});