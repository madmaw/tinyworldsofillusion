
illusionInit = function(
    minx, maxx,
    miny, maxy,
    playerRadius,
    playerTurretLength,
    playerMissileSpeed,
    levelScale,
    achievementThresholds
) {
    var illusion = {};
    var manualEntities = {};
    var score = 0;

    var leftDown = false;
    var rightDown = false;
    var manualRotation = 0;

    var playerRotationElement = document.getElementById("player-outline");
    var playerMultiplierElement = document.getElementById("player-multiplier");
    var missilesElement = document.getElementById("missiles");
    var targetsElement = document.getElementById("targets");
    var playerMissilePrototype = document.getElementById("player-missile");
    var colorWheelsElement = document.getElementById("color-wheels");
    var bonusesElement = document.getElementById("bonuses");

    var audioBonus = document.getElementById("audio-bonus");
    var audioReset = document.getElementById("audio-reset");
    var audioExplosion = document.getElementById("audio-explosion");
    var audioLaunch = document.getElementById("audio-launch");

    illusion.getPlayerRotation = function() {
        return illusion.getRotation(playerRotationElement);
    }

    illusion.getRotation = function(elem) {
        var rotation = 0;
        var numberOfItems = elem.transform.animVal.numberOfItems;
        for( var i=0; i<numberOfItems; i++ ) {
            var value = elem.transform.animVal.getItem(i);
            rotation += value.angle;
        }
        return rotation;

    }

    illusion.getAnimatedAttribute = function(element, attributeName) {
        var style = "body{"+element.getAttributeNS(null, "style")+"}";
        var parser = new CSSParser();
        var sheet = parser.parse(style, false, true);
        for(var i=0; i<sheet.cssRules.length; i++) {
            var cssRule = sheet.cssRules[i];
            for(var j=0; j<cssRule.declarations.length; j++ ) {
                var declaration = cssRule.declarations[j];
                if( declaration.property == attributeName ) {
                    return declaration.valueText;
                }
            }
        }
        // did not find it, use non-animated attribute
        return element.getAttributeNS(null, attributeName);
    }

    illusion.getElementsByName = function(element, name, list) {
        if( list == null ) {
            list = [];
        }
        if( element != null ) {
            if( element.getAttributeNS(null, "name") == name ) {
                list[list.length] = element;
            } else {
                var e = element.firstElementChild;
                while( e != null ) {
                    illusion.getElementsByName(e, name, list);
                    e = e.nextElementSibling;
                }
            }
        }
        return list;
    }

    illusion.getPosition = function(element) {
        var m = element.getCTM();
        var o = element.ownerSVGElement;
        var p = o.createSVGPoint();
        p.x = 0;
        p.y = 0;
        p = p.matrixTransform(m);
        p.x = (p.x + minx) / levelScale;
        p.y = (p.y + miny) / levelScale;
        return p;
    }

    illusion.subtractAngles = function(a1, a2) {
        var diffAngle = a1 - a2;
        while( diffAngle < -Math.PI ) {
            diffAngle += Math.PI * 2;
        }
        while( diffAngle > Math.PI ) {
            diffAngle -= Math.PI * 2;
        }
        return diffAngle;
    }

    illusion.getMultiplier = function() {
        var multiplier = parseInt(playerMultiplierElement.textContent);
        return multiplier;
    }

    illusion.incrementMultiplier = function() {
        var multiplier = illusion.getMultiplier();
        multiplier = multiplier + 1;
        playerMultiplierElement.textContent = ""+multiplier;
        audioBonus.play();
    }

    illusion.resetMultiplier = function() {
        playerMultiplierElement.textContent = "1";
        audioReset.play();
    }

    illusion.incrementScore = function(amount) {
        if( amount == null ) {
            amount = 1;
        }
        var multiplier = illusion.getMultiplier();
        var oldScore = score;
        score += multiplier * amount;
        // check score thresholds
        for( var i=0; i<achievementThresholds.length; i++ ) {
            var achievementThreshold = achievementThresholds[i];
            if( oldScore < achievementThreshold && score >= achievementThreshold ) {
                // activate!
                var animation = document.getElementById("achievement-"+i);
                if( animation ) {
                    animation.beginElement();
                }
            }
        }
    }

    illusion.fire = function() {
        var playerRotation = illusion.getPlayerRotation();
        var cos = Math.cos(playerRotation * Math.PI / 180);
        var sin = Math.sin(playerRotation * Math.PI / 180);
        var launchx = cos * playerTurretLength;
        var launchy = sin * playerTurretLength;
        var vx = cos * playerMissileSpeed;
        var vy = sin * playerMissileSpeed;
        var missile = {};
        audioLaunch.play();
        missile.cx = launchx;
        missile.cy = launchy;
        missile.vx = vx;
        missile.vy = vy;
        // work out which color wheel we are in
        var color = null;
        var colorWheel = colorWheelsElement.firstElementChild;
        while( colorWheel != null ) {
            // TODO check opacity
            var rangle = illusion.getRotation(colorWheel);

            var fromAngle = parseFloat(colorWheel.getAttributeNS(null, "fromangle")) + rangle;
            while(toAngle < fromAngle ) {
                toAngle += 360;
            }
            var toAngle = parseFloat(colorWheel.getAttributeNS(null, "toangle")) + rangle;
            var compareRotation = playerRotation;
            while( compareRotation > toAngle ) {
                compareRotation -= 360;
            }
            while( compareRotation < fromAngle ) {
                compareRotation += 360;
            }
            if( fromAngle <= compareRotation && toAngle >= compareRotation ) {
                color = colorWheel.getAttributeNS(null, "fill");
                break;
            }
            colorWheel = colorWheel.nextElementSibling;
        }
        if( color != null ) {
            // create an SVG representation of the missile and add that to the document
            var svgMissile = playerMissilePrototype.cloneNode(true);
            svgMissile.setAttributeNS(null, "transform", "translate("+missile.cx+","+missile.cy+") rotate("+playerRotation+")");
            svgMissile.setAttributeNS(null, "fill", color);

            var target = targetsElement.firstElementChild;
            var bestTarget = null;
            var bestColorTester = null;
            var bestDistanceSq = null;
            while( target != null ) {
                var colorTesters = illusion.getElementsByName(target, "color-tester");
                for( var i = 0; i<colorTesters.length; i++ ) {
                    var colorTester = colorTesters[i];
                    var targetColor = colorTester.getAttributeNS(null, "fill");
                    if( color == targetColor ) {
                        // check the opacity
                        var opacity = illusion.getAnimatedAttribute(colorTester, "opacity")
                        if( parseFloat(opacity) != 0 ) {
                            // check the angle
                            var position = illusion.getPosition(colorTester);
                            var angle = Math.atan2(position.y, position.x);
                            var diff = illusion.subtractAngles(playerRotation * Math.PI / 180, angle);
                            if( diff < Math.PI / 6 && diff > -Math.PI / 6 ) {
                                var dsq = position.x*position.x + position.y*position.y;
                                if( bestDistanceSq == null || bestDistanceSq > dsq ) {
                                    bestDistanceSq = dsq;
                                    bestColorTester = colorTester;
                                    bestTarget = target;
                                }
                            }
                            break;
                        }
                    }
                }
                target = target.nextElementSibling;
            }
            missilesElement.appendChild(svgMissile);

            missile.update = function() {
                var result;
                var rotation;
                if( bestTarget != null ) {
                    // nudge in that direction
                    var pos = illusion.getPosition(bestColorTester);
                    var dx = pos.x - missile.cx;
                    var dy = pos.y - missile.cy;

                    // check proximity
                    var dsq = dx*dx + dy*dy;
                    if( dsq < playerMissileSpeed*playerMissileSpeed ) {
                        targetsElement.removeChild(bestTarget);
                        illusion.incrementScore(1);
                        audioExplosion.play();
                        result = true;
                    } else {
                        result = false;
                    }

                    // TODO check proximity to everything else

                    var bestAngle = Math.atan2(dy, dx);
                    var vangle = Math.atan2(missile.vy, missile.vx);
                    var diffAngle = illusion.subtractAngles(bestAngle, vangle);
                    if( diffAngle < 0 ) {
                        diffAngle = Math.max(diffAngle, -0.03);
                    }
                    if( diffAngle > 0 ) {
                        diffAngle = Math.min(diffAngle, 0.03);
                    }
                    var angle = vangle + diffAngle;
                    missile.vx = Math.cos(angle) * playerMissileSpeed;
                    missile.vy = Math.sin(angle) * playerMissileSpeed;
                    //rotation = Math.atan2(missile.vy, missile.vx) * 180 / Math.PI;

                    rotation = angle * 180 / Math.PI;
                } else {
                    rotation = playerRotation;
                    result = false;
                }
                missile.cx = missile.cx + missile.vx;
                missile.cy = missile.cy + missile.vy;
                //playerMultiplierElement.textContent = ""+missile.cx+","+missile.cy;
                svgMissile.setAttributeNS(null, "transform", "translate("+missile.cx+","+missile.cy+") rotate("+rotation+")");
                var outOfBounds = missile.cx > maxx / levelScale || missile.cx < minx / levelScale || missile.cy > maxy / levelScale || missile.cy < miny / levelScale;
                if( outOfBounds ) {
                    illusion.resetMultiplier();
                }
                return result || outOfBounds;
            }
            missile.destroy = function() {
                missilesElement.removeChild(svgMissile);
            }
            manualEntities[0] = missile;
        }
    }

    document.onkeydown = function(evt) {
        var result;
        if( evt.keyCode == 87 || evt.keyCode == 69 ) {
            //w
            illusion.fire();
            result = true;
        } else if( evt.keyCode == 65 ) {
            // a
            rightDown = true;
        } else if( evt.keyCode == 68 ) {
            // d
            leftDown = true;
        } else {
            result = false;
        }
        return result;
    }

    document.onkeyup = function(evt) {
        if( evt.keyCode == 65 ) {
            // a
            rightDown = false;
        } else if( evt.keyCode == 68 ) {
            // d
            leftDown = false;
        }
        return evt.keyCode == 65 || evt.keyCode == 69 || evt.keyCode == 68 || evt.keyCode == 87;
    }

    playerRotationElement.ownerSVGElement.onmousedown = function(evt) {
        var x = (evt.clientX - playerRotationElement.ownerSVGElement.offsetLeft + minx) / levelScale;
        var y = (evt.clientY - playerRotationElement.ownerSVGElement.offsetTop + miny) / levelScale;
        var dsq = x*x + y*y;
        var ok = false;
        if( dsq < playerRadius * playerRadius ) {
            // is there a bonus active
            var bonus = bonusesElement.firstElementChild;
            while( bonus != null ) {
                var opacity = illusion.getAnimatedAttribute(bonus, "opacity");
                if( parseFloat(opacity) > 0 && !bonus.clicked ) {
                    illusion.incrementMultiplier();
                    var closeAnimations = illusion.getElementsByName(bonus, "close");
                    for( var i = 0; i<closeAnimations.length; i++ ) {
                        var closeAnimation = closeAnimations[i];
                        closeAnimation.beginElement();
                    }
                    bonus.clicked = true;
                    window.setTimeout(function(){
                        bonusesElement.removeChild(bonus);
                    }, 500);
                    ok = true;
                    break;
                }
                bonus = bonus.nextElementSibling;
            }
        }
        if( !ok ) {
            illusion.resetMultiplier();
        }
        return false;
    }

    illusion.update = function() {
        if( leftDown ) {
            manualRotation += 3;
        }
        if( rightDown ) {
            manualRotation -= 3;
        }
        if( leftDown || rightDown ) {
            playerRotationElement.setAttributeNS(null, "transform", "rotate("+manualRotation+")");
        }
        if( manualEntities[0] ) {
            if( manualEntities[0].update() ) {
                manualEntities[0].destroy();
                manualEntities[0] = null;
            }
        }
    }

    window.setInterval(illusion.update, 20);
}
