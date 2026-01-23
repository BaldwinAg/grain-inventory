/**
 * GrainTrack Authentication v1.0.0
 * Handles user authentication with Supabase Auth
 */

import { supabase } from './config.js';

/**
 * Sign in with email and password
 * @param {string} email
 * @param {string} password
 * @returns {Promise<{user: object|null, error: object|null}>}
 */
export async function signIn(email, password) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  });

  if (error) {
    console.error('Sign in error:', error.message);
    return { user: null, error };
  }

  return { user: data.user, error: null };
}

/**
 * Sign up with email and password
 * @param {string} email
 * @param {string} password
 * @param {object} metadata - Optional user metadata (name, etc.)
 * @returns {Promise<{user: object|null, error: object|null}>}
 */
export async function signUp(email, password, metadata = {}) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: metadata
    }
  });

  if (error) {
    console.error('Sign up error:', error.message);
    return { user: null, error };
  }

  return { user: data.user, error: null };
}

/**
 * Sign out the current user
 * @returns {Promise<{error: object|null}>}
 */
export async function signOut() {
  const { error } = await supabase.auth.signOut();

  if (error) {
    console.error('Sign out error:', error.message);
    return { error };
  }

  return { error: null };
}

/**
 * Get the current authenticated user
 * @returns {Promise<object|null>}
 */
export async function getCurrentUser() {
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

/**
 * Get the current session
 * @returns {Promise<object|null>}
 */
export async function getSession() {
  const { data: { session } } = await supabase.auth.getSession();
  return session;
}

/**
 * Send password reset email
 * @param {string} email
 * @returns {Promise<{error: object|null}>}
 */
export async function resetPassword(email) {
  const { error } = await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: window.location.origin + '/reset-password.html'
  });

  if (error) {
    console.error('Password reset error:', error.message);
    return { error };
  }

  return { error: null };
}

/**
 * Update user password (when logged in or from reset link)
 * @param {string} newPassword
 * @returns {Promise<{error: object|null}>}
 */
export async function updatePassword(newPassword) {
  const { error } = await supabase.auth.updateUser({
    password: newPassword
  });

  if (error) {
    console.error('Update password error:', error.message);
    return { error };
  }

  return { error: null };
}

/**
 * Subscribe to auth state changes
 * @param {function} callback - Called with (event, session) on auth changes
 * @returns {object} - Subscription object with unsubscribe method
 */
export function onAuthStateChange(callback) {
  const { data: { subscription } } = supabase.auth.onAuthStateChange(callback);
  return subscription;
}

/**
 * Check if user is authenticated
 * @returns {Promise<boolean>}
 */
export async function isAuthenticated() {
  const session = await getSession();
  return session !== null;
}
