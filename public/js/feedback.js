
const apiUrl = 'http://localhost:9094/api';

// Handle user feedback events
document.getElementById('send_msg').addEventListener('click', async (event) => {
    event.preventDefault(); // Prevent the form from submitting the traditional way

    const username = localStorage.getItem('loggedInUser');
    const msg = document.getElementById('msg').value;
    const email = localStorage.getItem('loggedInEmail');

    // Display "Please wait" message while processing
    document.getElementById('msg_result').textContent = 'Your massage is sending...';

    try {
        // Make a POST request 
        await axios.post(`${apiUrl}/msg`, { username,email,msg });

        // display a message
        document.getElementById('msg_result').textContent = 'Your massage sent successfully';
        // Redirect to the login page after 3 seconds
        setTimeout(() => {
            document.getElementById('msg_result').textContent = 'Thank you';
        }, 3000);

    } catch (error) {
        // Handle email sending failure 
        document.getElementById('msg_result').textContent = `Fail to send, please try again`;
    }
});



function cancel(){
    window.location.href = "pic (1).html";  // Redirect to home page on cancel button click.
}

