// Functional Launch Script

function main {
	print "Liftoff!".
	doLaunch().
	doAscent().
	until apoapsis > 100000 {
	  doAutoStage().
	}
	doShutdown().
	when alt:radar > 80000
		then executeManeuver(time:seconds + 30, 100, 100, 100).

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

function executeManeuver {
	parameter utime, radial, normal, prograde.
	local mnv is node(utime, radial, normal, prograde).
	addManeuverToFlightPlan(mnv). // passing the maneuver in as an argument to addManeuverToFlightPlan function
	local startTime is calculateStartTime(mnv).
	wait until time:seconds > startTime - 10.
	lockSteeringAtManeuverTarget(mnv).
	wait until time:seconds > startTime.
	lock throttle to 1.
	wait until isManeuverComplete(mnv).
	lock throttle to 0.
	removeManeuverFromFlightPlan(mnv).
}

function addManeuverToFlightPlan {
	parameter mnv.
	add mnv.

}

function calculateStartTime {
	parameter mnv.
	return time:seconds + mnv:eta - maneuverBurnTime(mnv) / 2.
}

function maneuverBurnTime {
	parameter mnv.
	// TODO
	return 10. 

}

function lockSteeringAtManeuverTarget {
	parameter mnv.
	lock steering to mnv:burnvector.
}

function isManeuverComplete {
	parameter mnv.
	if not(defined originalVector) or originalVector = 1 {
		declare global originalVector to mnv:burnvector.
	}
	if vang(originalVector, mnv:burnvector) > 90 {
		declare global originalVector to -1.
		return true.
	}
}

function removeManeuverFromFlightPlan {
	parameter mnv.
	remove mnv.
}

main().