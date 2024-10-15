
window.addEventListener('load', () => {
    const loggedInUser = localStorage.getItem('loggedInUser');  // Get the logged-in user's username
    const loggedInEmail = localStorage.getItem('loggedInEmail');
    if (loggedInUser) {
        // If the user is logged in, display their username
        document.getElementById('username').innerText = loggedInUser;  // Replace username placeholder with actual username
        document.getElementById('email').innerText = loggedInEmail;  // Replace email placeholder with actual email address
    } else {
        // If no user is logged in, redirect to the signup page
        window.location.href = 'sign.html';  // Redirect to registration page if user is not logged in
    }
});
function logout(){

    localStorage.removeItem('loggedInUser');  // Clear the logged-in user data
    window.location.href = 'index.html';  // Redirect to the login page
};

