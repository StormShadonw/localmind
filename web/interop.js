// web/interop.js
console.log("initializing interop.js");

if (!window.myAppInterop) {
    window.myAppInterop = {};
  }
  
  window.myAppInterop.aiAvailability = async function() {
    console.log('myAppInterop:', window.myAppInterop);
    console.log('klk22222:', window.myAppInterop);
    return await LanguageModel.availability();
  };