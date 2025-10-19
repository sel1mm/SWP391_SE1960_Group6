/* 
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/JavaScript.js to edit this template
 */

function validatePassword(password) {
    if (!password) return "Password cannot be empty.";
    if (password.length < 8) return "Password must be at least 8 characters long.";
    if (!/[A-Z]/.test(password)) return "Password must contain at least one uppercase letter.";
    if (!/[a-z]/.test(password)) return "Password must contain at least one lowercase letter.";
    if (!/[0-9]/.test(password)) return "Password must contain at least one digit.";
    if (!/[@$!%*?&]/.test(password)) return "Password must contain at least one special character (@, $, !, %, *, ?, &).";
    return null;
}

function checkPasswordInput(inputId, errorId) {
    const password = document.getElementById(inputId).value;
    const error = validatePassword(password);
    const errorElement = document.getElementById(errorId);
    if (error) {
        errorElement.textContent = error;
    } else {
        errorElement.textContent = "";
    }
}
