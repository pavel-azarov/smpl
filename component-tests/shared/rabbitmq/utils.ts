export const sleep = async (ms: number) => {
  return new Promise((resolve) => {
    setTimeout(resolve, ms)
  })
}

export const updateExpectedValueType = (actualValue: any, expectedValue: any) => {
  if (typeof actualValue === 'number') {
    return parseInt(expectedValue)
  } else if (actualValue === 'boolean') {
    return JSON.parse(expectedValue)
  }
  return expectedValue
}

export const getKeyValue = (key: string, obj: any) => {
  const keyArray = key.split('.')
  if (keyArray.length == 1) {
    return obj[key]
  } else if (keyArray.length == 2) {
    return obj[keyArray[0]][keyArray[1]]
  } else if (keyArray.length == 3) {
    return obj[keyArray[0]][keyArray[1]][keyArray[2]]
  }
}

export const getMessageByRoutingKey = (messages: any, routingKey: string, callback: Function) => {
  let error
  const messageArray: any = messages.filter((msg: any) => msg.type === routingKey)
  if (messageArray.length == 0) {
    error = `Unable to find message with routing key: ${routingKey}`
    return callback(error)
  } else if (messageArray.length > 1) {
    error = `There is more than one message with routing key: ${routingKey}`
    return callback(error)
  }
  return callback(error, messageArray[0])
}
