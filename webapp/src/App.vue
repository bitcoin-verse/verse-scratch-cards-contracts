<script setup>

import { RouterView } from 'vue-router'
import NavBar from './components/Navbar.vue'

{/* <RouterLink to="/about">About</RouterLink> */}

</script>

<template>

  <header>

  </header>
  
  <body>
    <NavBar />
    <RouterView />
  </body>
</template>

<style lang="scss">
body {
  width: 100%;
  min-height: 100vh;
  background-image: url("./assets/bg-pilot.jpeg");
  background-size: cover;
  margin: 0;
  font-family: 'Montserrat', sans-serif;
  background-color: #171c2b;
}

#app {
  width: 100%;
  min-height: 100vh;
}

svg {
  display: none!important;
}

.lds-ring {
  display: inline-block;
  position: relative;
  width: 80px;
  height: 80px;
}
.lds-ring div {
  box-sizing: border-box;
  display: block;
  position: absolute;
  width: 64px;
  height: 64px;
  margin: 8px;
  border: 8px solid #fff;
  border-radius: 50%;
  animation: lds-ring 1.2s cubic-bezier(0.5, 0, 0.5, 1) infinite;
  border-color: #fff transparent transparent transparent;
}
.lds-ring div:nth-child(1) {
  animation-delay: -0.45s;
}
.lds-ring div:nth-child(2) {
  animation-delay: -0.3s;
}
.lds-ring div:nth-child(3) {
  animation-delay: -0.15s;
}
@keyframes lds-ring {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.backdrop {
    position: fixed; 
    top: 0;
    left: 0;
    width: 100%;
    height: 100vh;
    background-color: #4343438f;
    z-index: 2;

    .modal {
        @media(max-width: 880px) {
            width: 100%;
            position: absolute;
            width: 90%;
            left: 0;
            padding: 5%;
        }
        box-shadow: 0 0 20px rgba(17, 17, 29, 0.7);
        width: 450px;
        position: absolute;
        left: calc(50% - 225px);
        top: 180px;
        background-color: #1c1b21;
        border-radius: 5px;
        padding: 30px;
        h3 {
            margin-top: 0;
            color: white;
        }
        p {
            color: white;
        }
        p.iholder {
            text-align:right;
            margin-top: 0;
            margin-right: 5px;
            margin-bottom: 0;
            color: white;
            i {
                cursor: pointer;
            }
        }
    }


}

</style>
