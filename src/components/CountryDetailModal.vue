<script>
import { toRaw } from 'vue';
import CloseIcon from './icons/CrossXIcon.vue';


export default {
  data() {
    return {
      flags: '',
    };
  },
  props: [
    'country'
  ],
  components: {
    CloseIcon,
  },
  mounted() {
    this.showRawCountry();
  },
  methods: {
    closeModal() {
      this.$emit('closeModal');
    },
    showRawCountry() {
      console.log(this.country);
      const flag = toRaw(this.country.flags.png)
      this.flags = flag

    },
  },

};
</script>


<template>
  <div class="h-screen fixed inset-0 z-50 flex items-center justify-center">

    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50"></div>
    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50"></div>
    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50"></div>


    <div class="w-full bg-white h-[660px] max-w-screen-lg rounded-lg z-10 overflow-y-auto">
      <div class="shadow-md bg-gray-500 p-6 sticky top-0 flex justify-between items-center">

        <h2 class="text-white text-3xl font-semibold">Country Detail</h2>

        <button @click="closeModal" class="animate-bounce">
          <CloseIcon />
        </button>
      </div>


      <!-- Modal Body -->
      <div class="w-fit h-fit grid grid-cols-3 grid-rows-5 gap-4 text-center justify-center items-center">

        <div class="col-span-3 row-span-1 py-2 px-4 flex justify-center items-center">
          <img :src="flags" alt="Flag" class="w-fit h-fit object-cover rounded mb-2" />
        </div>
        <div class="col-span-1 row-span-1"><strong>Common name:</strong> {{ country.name.common }}</div>
        <div class="col-span-1 row-span-1"><strong>Official name:</strong>{{ country.name.official }}</div>
        <div class="col-span-1 row-span-1"><strong>Capital:</strong> 
          <template v-for="(capital, code) in country.capital" :key="code">
            &nbsp;{{ capital }} 
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Car side:</strong> {{ country.car.side }}</div>
        <!-- <div class="col-span-1 row-span-1"><strong>Currencies:</strong> {{ country.currencies }}</div> -->
        <div class="col-span-1 row-span-1"><strong>Currencies:</strong> <br>
          <template v-for="(currency, code) in country.currencies" :key="code">
           Name: {{ currency.name }} ({{ code }}), Symbol ({{ currency.symbol }})<br>
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Continents:</strong> {{ country.continents[0] }}</div>
        <div class="col-span-1 row-span-1"><strong>Population:</strong> {{ country.population }}</div>
        <div class="col-span-1 row-span-1"><strong>Language:</strong> 
          <template v-for="(languages, code) in country.languages" :key="code">
            &nbsp;{{ languages }}
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Map:</strong> <a href="country.maps.googleMaps"
            class="text-blue-600 hover:underline">{{ country.maps.googleMaps }}</a></div>
        <div class="col-span-1 row-span-1"><strong>Region:</strong> {{ country.region }}</div>
        <div class="col-span-1 row-span-1"><strong>Subregion:</strong> {{ country.subregion }}</div>
        <div class="col-span-1 row-span-1"><strong>Timezone:</strong>
          <template v-for="(timezones, code) in country.timezones" :key="code">
            &nbsp;{{ timezones }}
          </template>
        </div>
      </div>

    </div>
  </div>
</template>