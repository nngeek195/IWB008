// Base URL of your backend API with the /api prefix
const apiUrl = 'http://localhost:9090/api';

// Handle user login
document.getElementById('log').addEventListener('click', async (event) => {
    event.preventDefault(); // Prevent the form from submitting the traditional way
    const superUser = "admin";
    const superuserpassword = "admin";
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;

    if(username === superUser && password === superuserpassword){
        localStorage.setItem('loggedInUser', username);
        window.location.href= 'pic (1).html';
    }else{

    try {
        const response = await axios.post(`${apiUrl}/login`, {
            username,
            password
        });

        // If login is successful, store the username in localStorage and redirect to the next page
        localStorage.setItem('loggedInUser', username);  // Save username in local storage to make user control 
        document.getElementById('loginResult').textContent = 'Login successful!';
        window.location.href = 'pic (1).html';  // Redirect to the function page
    } catch (error) {
        // Show error message if login fails
        document.getElementById('loginResult').textContent = `Login failed: Invalid username or password.`;
    }}
});

//foget button redirection
document.getElementById("foget").addEventListener("click", function(){
    window.location.href = "foget.html"; //redirect to fogetpage
});

