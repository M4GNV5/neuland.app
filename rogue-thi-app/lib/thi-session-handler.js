import { isAlive, login } from './thi-api-client'

const SESSION_EXPIRES = 3 * 60 * 60 * 1000

export class NoSessionError extends Error {

}

export async function createSession (router, username, password, stayLoggedIn) {
  // convert to lowercase just to be safe
  // (the API used to show weird behavior when using upper case usernames)
  username = username.toLowerCase()
  // strip domain if user entered an email address
  username = username.replace(/@thi\.de$/, '')

  const session = await login(username, password)

  localStorage.session = session
  localStorage.sessionCreated = Date.now()

  if (stayLoggedIn) {
    localStorage.username = username
    localStorage.password = password
  } else {
    delete localStorage.username
    delete localStorage.password
  }

  router.replace('/')
}

export async function callWithSession (method) {
  let session = localStorage.session
  const sessionCreated = parseInt(localStorage.sessionCreated)
  const username = localStorage.username
  const password = localStorage.password

  // log in if there is no session or the session is older than SESSION_EXPIRES
  if ((!session || sessionCreated + SESSION_EXPIRES < Date.now()) && username && password) {
    try {
      console.log('no session, logging in...')
      session = await login(username, password)
      localStorage.session = session
      localStorage.sessionCreated = Date.now()
    } catch (e) {
      throw new NoSessionError()
    }
  }

  // otherwise attempt to call the method and see if it throws a session error
  try {
    return await method(session)
  } catch (e) {
    // the backend can throw different errors such as 'No Session' or 'Session Is Over'
    if (/session/i.test(e.message)) {
      if (username && password) {
        console.log('seems to have received a session error trying to get a new session!')
        try {
          session = await login(username, password)
          localStorage.session = session
          localStorage.sessionCreated = Date.now()
        } catch (e) {
          throw new NoSessionError()
        }

        return await method(session)
      } else {
        throw new NoSessionError()
      }
    } else {
      throw e
    }
  }
}

export async function obtainSession (router) {
  let session = localStorage.session
  const age = parseInt(localStorage.sessionCreated)
  const username = localStorage.username
  const password = localStorage.password

  // invalidate expired session
  if (age + SESSION_EXPIRES < Date.now() || !await isAlive(session)) {
    console.log('Invalidating session')

    session = null
  }

  // try to log in again
  if (!session && username && password) {
    try {
      console.log('Logging in again')

      session = await login(username, password)
      localStorage.session = session
      localStorage.sessionCreated = Date.now()
    } catch (e) {
      console.log('Failed to log in again')

      console.error(e)
    }
  }

  if (session) {
    return session
  } else {
    router.replace('/login')
    return null
  }
}

export async function forgetSession (router) {
  delete localStorage.session
  delete localStorage.sessionCreated
  delete localStorage.username
  delete localStorage.password

  router.replace('/login')
}
