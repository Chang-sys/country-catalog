<template>
    <div class="modal">
      <div class="modal-content">
        <span class="close" @click="closeModal">&times;</span>
        <h2>{{ selectedCountry.name.official }} Details</h2>
        <!-- Add more details here -->
      </div>
    </div>
  </template>
  
  <script>
  export default {
    props: {
      selectedCountry: Object,
    },
    methods: {
      closeModal() {
        this.$emit('closeModal');
      },
    },
  };
  </script>
  
  <style scoped>
  /* Add your styles here */
  </style>
  