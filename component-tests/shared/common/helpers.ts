import winston, {format} from 'winston'
import {LOG_LEVEL} from '../config'
import {IdTokenData} from './http-data-structures'
import jwt from 'jsonwebtoken'
import {private_key} from './id_token_private_key'

export function throwIfNullOrUndefined<T = any>(
  value: T | null | undefined,
  msg?: string,
): value is T {
  if (value === null || value === undefined) {
    throw new Error(msg || 'value is not defined')
  }
  return true
}

// There are numerous libraries in npm that can sleep,
// however installing a few of these didn't work in our docker CI environment
// so we will just define the function here.
export function sleep(ms: number) {
  return new Promise((resolve) => {
    setTimeout(resolve, ms)
  })
}

export const logger = winston.createLogger({
  transports: [
    new winston.transports.Console({
      level: LOG_LEVEL,
      format: format.prettyPrint({colorize: true}),
    }),
  ],
})

export function generateIdToken(data: IdTokenData): string {
  return jwt.sign(
    {
      iss: data.iss,
      sub: data.sub,
      aud: data.aud,
      iat: data.iat,
      exp: data.exp,
      name: data.name,
      email: data.email,
    },
    private_key,
    {
      keyid: '1e9gdk7',
      algorithm: 'RS256',
    },
  )
}
