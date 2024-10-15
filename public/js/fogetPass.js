
const apiUrl = 'http://localhost:9095/api';

// Handle foget password 
document.getElementById('foget').addEventListener('click', async (event) => {
    event.preventDefault(); // Prevent the form from submitting the traditional way

    const username = document.getElementById('username').value;
    const email = document.getElementById('email').value;

    // Display "Please wait" message while processing
    document.getElementById('msg_result').textContent = 'Your request is sending...';

    try {
        // Make a POST request 
        await axios.post(`${apiUrl}/foget`, { username,email });

        // On success, display a welcome message and redirect to the login page
        document.getElementById('msg_result').textContent = 'Your request accepted!';
        // Redirect to the login page after 3 seconds
        setTimeout(() => {
            document.getElementById('msg_result').textContent = 'Check your mail box';
        }, 3000);

    } catch (error) {
        // Handle email sending failure or other errors
        document.getElementById('msg_result').textContent = `Check your username and Email`;
    }
});


