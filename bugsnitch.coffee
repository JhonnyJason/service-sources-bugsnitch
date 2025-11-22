############################################################
#region debug
import { createLogFunctions } from "thingy-debug"
{log, olog} = createLogFunctions("bugsnitch")
#endregion

############################################################
import net from "node:net"

############################################################
#region Local Variables
setReady = null
ready = new Promise (rslv) -> setReady = rslv

############################################################
socketPath = "/run/bugsnitch.sk"

############################################################
serviceName = "unnamed"
serviceVersion = "0.0.0" 

#endregion

############################################################
export initialize = (c) ->
    log "initialize"
    if c.snitchSocket then socketPath = c.snitchSocket
    if c.name then serviceName = c.name
    if c.version then serviceVersion = c.version
    setReady()
    return

############################################################
sendToBugsnitch = (msg) ->
    log "sendToBugsnitch"
    await ready
    sock = net.createConnection(socketPath)
    sock.on("connect", (() -> sock.end(msg)))
    sock.on("error", ((e) -> console.error(e)))
    sock.on("close", (() -> log "Connection closed!"))
    return

############################################################
export report = (error) ->
    log "report"
    console.error(error)
    if typeof error == "string"
        msg = "[#{serviceName}]: #{error}"
        sendToBugsnitch(msg)
        return
    
    try
        msg = "[#{serviceName}] Error: "+error.message
        if error.cause then msg += "\n Cause: "+error.cause
        if error.stack then msg += "\n Stack: "+error.stack
        sendToBugsnitch(msg)
        return
    catch err then console.error("bugsnitch.report: unexpected errorObject!\n "+err.message)
    return
