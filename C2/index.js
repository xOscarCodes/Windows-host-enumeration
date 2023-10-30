const express = require('express');
const bodyParser = require('body-parser');
const fs = require('fs');
const app = express();
const port = process.env.PORT || 3000;

// Create an array to store log entries
const logEntries = [];

// Create a write stream to the log file
const logFilePath = 'windows_enum_logs.json';

// Read existing logs from the JSON file, if it exists
if (fs.existsSync(logFilePath)) {
    const existingLogs = fs.readFileSync(logFilePath);
    logEntries.push(...JSON.parse(existingLogs));
}

const logCommandEntries = [];

const commandFilePath = 'api_command_logs.json';

// Read existing logs from the JSON file, if it exists
if (fs.existsSync(commandFilePath)) {
    const existingCommandLogs = fs.readFileSync(commandFilePath);
    logEntries.push(...JSON.parse(existingCommandLogs));
}

// Parse JSON request body
app.use(bodyParser.json());

// Define a route to handle the POST request
app.post('/api/endpoint', (req, res) => {
    const  CommandOutput  = req.body;

    // Get the IP address from which the request is generated
    const clientIp = req.ip;

    // Log the IP address and received command output
    const logEntry = {
        timestamp: new Date().toUTCString(),
        ip: clientIp,
        commandOutput: CommandOutput,
    };

    logEntries.push(logEntry);

    // Write the updated log entries to the JSON file
    fs.writeFileSync(logFilePath, JSON.stringify(logEntries, null, 2));

    // Respond with a success message
    res.status(200).json({ message: 'Command output received successfully' });
});

app.post('/api/endpoint/command', (req, res) => {
    const  CommandOutput  = req.body;

    // Get the IP address from which the request is generated
    const clientIp = req.ip;

    // Log the IP address and received command output
    const logEntry = {
        timestamp: new Date().toUTCString(),
        ip: clientIp,
        commandOutput: CommandOutput,
    };

    logCommandEntries.push(logEntry);

    // Write the updated log entries to the JSON file
    fs.writeFileSync(logCommandEntries, JSON.stringify(logCommandEntries, null, 2));

    // Respond with a success message
    res.status(200).json({ message: 'Command output received successfully' });
});

// Start the Express server
app.listen(port, () => {
    console.log(`Server is running on port ${port}`);
});
