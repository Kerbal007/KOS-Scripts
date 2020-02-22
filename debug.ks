// Functional Launch Script

function main {
    doLaunch().
    doAscent().
    until apoapsis > 100000 {
        doAutoStage().
    }
    doShutdown().
}

function doLaunch {
    lock throttle to 1.
    doSafeStage().
    doSafeStage(). 
}

//select a block to comment out with ctrl+K then ctrl+C
function doAscent {
    lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
    set targetDirection to 90.
    lock steering to heading(targetDirection, targetPitch).
}

function doAutoStage {
    if not(defined oldThrust) {
        declare global oldThrust to ship:availablethrust.
    }
    if ship:availablethrust < (oldThrust - 10) {
        doSafeStage(). wait 1.
        declare global oldThrust to ship:availablethrust.
    }
}

function doShutdown {
    lock throttle to 0.
    lock steering to prograde.
    wait until false.
}

function doSafeStage {
    wait until stage:ready.
    stage.
}

main().