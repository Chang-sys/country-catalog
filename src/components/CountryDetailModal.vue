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
      const flag = toRaw(this.country.flags.png)
      this.flags = flag
    },
  },

};
</script>


<template>
  <div class="h-screen fixed inset-0 z-50 flex items-center justify-center" @click.stop>

    <!-- Blur by color -->
    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50"></div>
    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50"></div>
    <div class="blur-2xl absolute inset-0 bg-gray-900 opacity-50" @click="closeModal"></div>

    <div class="w-full bg-white h-[660px] max-w-screen-lg rounded-lg z-10 overflow-y-auto">

      <!-- Header -->
      <div class="shadow-md bg-gray-300 p-6 sticky top-0 flex justify-between items-center">
        <h2 class="text-black text-3xl font-semibold">Country Detail</h2>
        <button @click="closeModal" class="animate-bounce">
          <CloseIcon />
        </button>
      </div>
      <!-- endHeader -->

      <!-- Modal Body -->
      <div class="w-fit h-screen grid grid-cols-3 grid-rows-5 gap-1 text-center justify-center items-center">
        <div class="col-span-3 row-span-1 py-2 px-2 flex justify-center items-center">
          <img :src="flags" alt="Flag" class="w-fit h-fit object-cover rounded mb-2" />
        </div>
        <div class="col-span-1 row-span-1"><strong>Common name:</strong> <br /> {{ country.name.common }}</div>
        <div class="col-span-1 row-span-1"><strong>Official name:</strong> <br /> {{ country.name.official }}</div>
        <div class="col-span-1 row-span-1"><strong>Capital:</strong> <br />
          <template v-for="(capital, code) in country.capital" :key="code">
            &nbsp;{{ capital }}
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Car side:</strong> <br /> {{ country.car.side }}</div>
        <div class="col-span-1 row-span-1"><strong>Currencies:</strong> <br>
          <template v-for="(currency, code) in country.currencies" :key="code">
            Name: {{ currency.name }} ({{ code }}), Symbol ({{ currency.symbol }})<br>
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Continents:</strong> <br /> {{ country.continents[0] }}</div>
        <div class="col-span-1 row-span-1"><strong>Population:</strong> <br /> {{ country.population }}</div>
        <div class="col-span-1 row-span-1"><strong>Language:</strong> <br />
          <template v-for="(languages, code) in country.languages" :key="code">
            &nbsp;{{ languages }}
          </template>
        </div>
        <div class="col-span-1 row-span-1"><strong>Map:</strong> <a href="country.maps.googleMaps"
            class="text-blue-600 hover:underline">{{ country.maps.googleMaps }}</a></div>
        <div class="col-span-1 row-span-1"><strong>Region:</strong> <br /> {{ country.region }}</div>
        <div class="col-span-1 row-span-1"><strong>Subregion:</strong> <br /> {{ country.subregion }}</div>
        <div class="col-span-1 row-span-1"><strong>Timezone:</strong> <br />
          <template v-for="(timezones, code) in country.timezones" :key="code">
            &nbsp;{{ timezones }}
          </template>
        </div>
      </div>
      <!-- end Modal Boday -->

    </div>
  </div>
</template>