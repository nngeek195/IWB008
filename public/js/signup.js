// Base URL of your backend API with the /api prefix
const apiUrl = 'http://localhost:9090/api';

// Helper function to check if the password is strong
function isStrongPassword(password) {
    const strongPasswordPattern = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/;
    return strongPasswordPattern.test(password);
}

// Helper function to check if the username contains a number
function isValidUsername(username) {
    const usernamePattern = /[0-9]/;
    return usernamePattern.test(username);
}

document.getElementById('signupForm').addEventListener('submit', async (event) => {
    event.preventDefault();

    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    const email = document.getElementById('email').value;

    // Clear any previous result messages
    document.getElementById('signupResult').textContent = '';

    // Validate the username to contain at least one number
    if (!isValidUsername(username)) {
        document.getElementById('signupResult').textContent = 'Username must contain at least one number.';
        return;
    }

    // Validate the password strength
    if (!isStrongPassword(password)) {
        document.getElementById('signupResult').textContent = 'Password must be at least 8 characters long and include an uppercase letter, a lowercase letter, a number, and a special character.';
        return;
    }

    // Display "Please wait" message while processing
    document.getElementById('signupResult').textContent = 'Please wait while we confirm your details...';

    try {
        // Make a POST request to the signup API
        await axios.post(`${apiUrl}/signup`, { username, password, email });

        // On success, display a welcome message and redirect to the login page
        document.getElementById('signupResult').textContent = 'Signup successful! Welcome email sent. Redirecting to login...';
        localStorage.setItem('loggedInEmail', email);  // Save username in local storage
        // Redirect to the login page after 3 seconds
        setTimeout(() => {
            window.location.href = 'login.html';
        }, 3000);

    } catch (error) {
        // Handle email sending failure or other issues
        document.getElementById('signupResult').textContent = `Signup failed: Email or username already exists.`;
    }
});
