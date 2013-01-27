console.log('This would be the main JS file.');
<<<<<<< HEAD

function ShowOverlay(divID) {
var divObject = document.getElementById(divID);
divObject.style.visibility = "visible";
}
function HideOverlay(divID) {
var divObject = document.getElementById(divID);
divObject.style.visibility = "hidden";
}

function overlay(mode) {
   if(mode == 'display') {
       if(document.getElementById("overlay") === null) {
           div = document.createElement("div");
           div.setAttribute('id', 'overlay');
           div.setAttribute('className', 'overlayBG');
           div.setAttribute('class', 'overlayBG');
           document.getElementsByTagName("body")[0].appendChild(div);
       }
   } else {
       document.getElementsByTagName("body")[0].removeChild(document.
         getElementById("overlay"));
   }
}
=======
>>>>>>> 145f2ff7ba6173d9b3cb64e5a92a61b91490dbd4
