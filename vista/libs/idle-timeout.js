 function controlInactividad(idleMinInput, warningMinInput, logoutUrl) {
     var t;
     var activeTime;
     var warningCountdown;
     var sessExpirDiv = document.getElementById('sessExpirDiv');
     window.onload = resetTimer; /* Window is refreshed. */
     // window.onmousemove = resetTimer; /* Mouse is moved. */
     window.onkeypress = resetTimer; /* Key is pressed. */
     // window.onmousedown = resetTimer; /* Touchscreen is pressed. */
     window.onclick = resetTimer; /* Touchpad clicks. */
     window.onscroll = resetTimer; /* Scrolling with arrow keys. */
     function warning(idleSeconds, warningSeconds) {
         warningStart = setTimeout(function() {
             sessExpirDiv.style.opacity = '1';
             sessExpirDiv.style.zIndex = '999999';
         }, 1000); /* Wtihout this, warning div would appear before the text. */
         remaining = idleSeconds - warningSeconds;
         warningCountdown = setInterval(function() { /* Update every 1 second. */
             if (remaining <= 0) {
                 /* Now we check that no other tab has been active after us. */
                 var browserActive = localStorage.getItem('activeTime');
                 if (activeTime != browserActive) { /* Then another tab has been active more recently than this tab. */
                     // alert("Not the same. User has been active in another tab. browserActive: " + browserActive + " and activeTime: " + activeTime);
                     /* We want to keep going, because user might close the other tab - and if this script is broken, the controlInactividad is broken. */
                     controlInactividad(idleMinInput, warningMinInput, logoutUrl);
                 } else {
                     // alert("The same. User has not been active in another tab. browserActive: " + browserActive + " and activeTime: " + activeTime);
                     logout();
                 }
             } else {
                 remaining -= 1;
                 document.getElementById('sessExpirDiv').innerHTML =
                     `<div class="row center">
                     <div class="col s12  center">
                        <div class="card red darken-4 center">
                            <div class="card-content white-text">
                                <span class="card-title">Alerta</span>
                                    <p>Esto se va a cerrar. Use el teclado ó el mouse para mantener logueado  
                                        ${remaining} segundos restantes </p> 
                            </div> 
                        <div class="card-action black">
                            <a href="./index.html">Terminar</a> <a href="#">Mantener</a>
                        </div>
                    </div>
                </div>
            </div>`;

             }
         }, 1000);
     }

     function recordTime() {
         activeTime = Date.now(); /* Milliseconds since 1970/01/01. */
         localStorage.setItem('activeTime', activeTime);
     }

     function clearEverything() {
         clearTimeout(t);
         clearInterval(warningCountdown);
         clearWarning();
     }

     function clearWarning() {
         sessExpirDiv.style.opacity = '0';
         sessExpirDiv.innerHTML = ' ';
         sessExpirDiv.style.zIndex = '-999999';
     }

     function logout() {
         window.location.href = logoutUrl;
     }

     function resetTimer() {
         console.log("leooooooddddddd");
         clearEverything();
         recordTime(); /* Records across all tabs in browser. */
         var idleMinutes = idleMinInput; /* After how long idle time do we log out user? */
         var warningMinutes = warningMinInput; /* After how long idle time do we start the warning countdown? */
         var idleSeconds = parseInt(idleMinutes * 60);
         var warningSeconds = parseInt(warningMinutes * 60);
         var wMilliSeconds = warningSeconds * 1000;
         /* When user has been idle warningSeconds number of seconds, we display warning and countdown. */
         t = setTimeout(function() { warning(idleSeconds, warningSeconds); }, wMilliSeconds);
     }
 };


 // export class ControlDeInactividad {

 //     constructor(propiedades = {
 //         titulo,
 //         mensaje,
 //         inactividad,
 //         conteoRegresivo,
 //         monitoreo: { intervalo, clase, accion, rspuesta },
 //         accion

 //     }) {
 //         propiedades.inactividad = 3;
 //         propiedades.idTimeout = null;
 //         propiedades.reiniciar = true;
 //         propiedades.materialDialog;
 //         this.monitorearSesion(propiedades);

 //         // this.idleTimeout;

 //         // // Init on page load
 //         // this.resetIdleTimeout(propiedades);

 //         // // Reset the idle timeout on any of the events listed below
 //         // ['click', 'touchstart', 'mousemove'].forEach(evt =>
 //         //     document.addEventListener(evt, this.resetIdleTimeout, propiedades, false)
 //         // );
 //     };
 //     iniciarInactividad(propiedades) {

 //         if (propiedades.reiniciar) {
 //             if (propiedades.idTimeout) {
 //                 propiedades.idTimeout;
 //             }

 //             this.idleTimeout = setTimeout(() => {
 //                 // location.href = this.redirectUrl;
 //                 x(propiedades)
 //             }, propiedades.inactividad * 1000);

 //             //         	Configurar el contador de tiempo de inactividad propiedades.idTimeout
 //             // Configurar un MaterialDialog con los botones 'Sí, terminar' y 'No, continuar',
 //             // El primero para llamar al callBack ‘Acción’ dado como argumento en la creación de la instancia de tipo ControlDeInactividad.
 //             //  El segundo para que cuando se pulse clic sobre el, se detenga el conteo regresivo.

 //             let cuentaRegresiva = 0;

 //             propiedades.conteoRegresivo
 //                 // En cada segundo incrementar el conteo y actualizar el mensaje de 
 //                 // conteo regresivo

 //             if se alcanza el límite de espera para que el usuario reaccione {
 //                 // llamar al callBack ‘Acción’ dado como argumento en la creación de 
 //                 // la instancia
 //             }

 //             propiedades.reiniciar = true;
 //         }
 //     };

 //     monitorearSesion(propiedades) {
 //         ['click', 'touchstart', 'mousemove'].forEach(evt =>
 //             document.addEventListener(evt, iniciarInactividad(propiedades), propiedades.reiniciar = true, false)
 //         );
 //         // Para cada evento 'click', 'touchstart' o 'mousemove' establecer como acciones {
 //         //    propiedades.reiniciar = true;
 //         //    iniciarInactividad(propiedades);
 //     }

 //     CuadroDialogo(propiedades) {
 //         MaterialDialog.dialog(propiedades.mensaje, {
 //             title: propiedades.titulo,
 //             buttons: {
 //                 close: {
 //                     text: 'Terminar',
 //                     callback: propiedades.accion
 //                 },
 //                 confirm: {
 //                     text: 'Continuar',
 //                     callback: () => propiedades.monitoreo.accion
 //                 }
 //             }
 //         });
 //     }

 //     // Forzar a que ocurra uno de los eventos anteriores

 //     // Aquí es necesario utilizar setInterval con un callBack que se encargue de solicitar al back-end la verificación de la sesión, es decir, si el status de la misma es activo o no.  Esto debe hacerse en el intervalo de segundos establecido para el monitoreo.

 //     // Si llegase a suceder que la sesión ya no esté activa, entonces se dispara la función asignada al callBack ‘accion’. Ver el ejemplo de creación del objeto.
 // }




 // CuadroDialogo(propiedades) {
 //     MaterialDialog.dialog(propiedades.mensaje, {
 //         title: propiedades.titulo,
 //         buttons: {
 //             close: {
 //                 text: 'Terminar',
 //                 callback: propiedades.accion
 //             },
 //             confirm: {
 //                 text: 'Continuar',
 //                 callback: () => propiedades.monitoreo.accion
 //             }
 //         }
 //     });
 // }

 // resetIdleTimeout(propiedades) {
 //     let x = this.CuadroDialogo;
 //     // Clears the existing timeout
 //     if (this.idleTimeout) {
 //         clearTimeout(this.idleTimeout);
 //     }

 //     // Set a new idle timeout to load the redirectUrl after idleDurationSecs
 //     this.idleTimeout = setTimeout(() => {
 //         // location.href = this.redirectUrl;
 //         x(propiedades)
 //     }, propiedades.inactividad * 1000);
 // };








 // function idleTimer() {
 //     var t;
 //     //window.onload = resetTimer;
 //     window.onmousemove = resetTimer; // catches mouse movements
 //     window.onmousedown = resetTimer; // catches mouse movements
 //     window.onclick = resetTimer; // catches mouse clicks
 //     window.onscroll = resetTimer; // catches scrolling
 //     window.onkeypress = resetTimer; //catches keyboard actions

 //     function logout() {
 //         window.location.href = '/action/logout'; //Adapt to actual logout script
 //     }

 //     function reload() {
 //         window.location = self.location.href; //Reloads the current page
 //     }

 //     function resetTimer() {
 //         clearTimeout(t);
 //         t = setTimeout(logout, 1800000); // time is in milliseconds (1000 is 1 second)
 //         t = setTimeout(reload, 300000); // time is in milliseconds (1000 is 1 second)
 //     }
 // }
 // idleTimer();