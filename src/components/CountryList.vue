<script>
// Import Fuzzysort
import fuzzysort from 'fuzzysort';
import CountryDetailModal from './CountryDetailModal.vue';
import SortIcon from './icons/SortIcon.vue';
// Icon filter Asc from A to Z or 0 to 9
import SortAscIcon from './icons/SortAscIcon.vue';
// Icon filter Desc from Z to A or 9 to 0
import SortDescIcon from './icons/SortDescIcon.vue';

import { toRaw } from 'vue';

export default {
  data() {
    return {
      countries: [],
      searchQuery: "",
      sortOrder: "asc",
      sortOrderIcon: 'default',
      currentPage: 1,
      itemsPerPage: 25,
      selectedCountry: null,
    };
  },
  components: {
    SortIcon,
    SortAscIcon,
    SortDescIcon,
    CountryDetailModal,
  },
  mounted() {
    // console.log("API mounted");
    this.fetchCountries();
  },
  methods: {
    async fetchCountries() {
      try {
        const response = await fetch("https://restcountries.com/v3.1/all");
        const data = await response.json();
        this.countries = data;
      } catch (error) {
        console.error("Error fetching countries:", error);
      }
    },
    toggleSortOrder() {
      if (this.sortOrderIcon === 'asc') {
        this.sortOrderIcon = 'desc';
      } else if (this.sortOrderIcon === 'desc') {
        this.sortOrderIcon = 'default';
      } else {
        this.sortOrderIcon = 'asc';
      }

      this.sortCountries(); // Call the sorting function when the button is clicked
    },
    sortCountries() {
      let sortOrderFactor;

      if (this.sortOrderIcon === 'asc') {
        sortOrderFactor = 1;
      } else if (this.sortOrderIcon === 'desc') {
        sortOrderFactor = -1;
      } else {
        // If the order is 'default', reset to the original order fetched from the API
        this.fetchCountries();
        return;
      }

      this.countries.sort((a, b) => {
        const nameA = a.name.official.toLowerCase();
        const nameB = b.name.official.toLowerCase();

        return sortOrderFactor * nameA.localeCompare(nameB);
      });
    },

    formatCountryId(idd) {
      const root = idd.root || ''; // Handle the case when root is undefined
      const suffixes = idd.suffixes ? idd.suffixes.join('') : '';
      const fullString = root + suffixes;

      if (fullString.length > 25) {
        // If the string is longer than 25 characters, truncate it and add "..."
        return fullString.substring(0, 25) + '...';
      } else if (fullString.length > 7) {
        // If the string is longer than 7 characters, add a comma every 7 characters
        const chunks = [];
        for (let i = 0; i < fullString.length; i += 7) {
          chunks.push(fullString.substring(i, i + 7));
        }
        return chunks.join(',');
      } else {
        // Otherwise, return the original string
        return fullString;
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages) {
        this.currentPage += 1;
      }
    },
    prevPage() {
      if (this.currentPage > 1) {
        this.currentPage -= 1;
      }
    },
    isUnique(name) {
      if (!this.uniqueNames) {
        this.uniqueNames = new Set();
      }
      if (this.uniqueNames.has(name)) {
        return false;
      }
      this.uniqueNames.add(name);
      return true;
    },
    // Open and close the modal with the selected country
    showCountryModal(country) {
      // Use toRaw to access the raw object
      const oneCountry = toRaw(country);
      this.selectedCountry = oneCountry;
    },
    closeCountryModal() {
      this.selectedCountry = null;
    },

  },
  computed: {
    searchAndSortCountries() {
      // Use Fuzzysort to search by country name
      const searchResults = fuzzysort
        .go(this.searchQuery, this.countries, { key: 'name.official' })
        .map(result => result.obj);

      // If no search query or no matching results, return the original countries with sorting
      if (!this.searchQuery || searchResults.length === 0) {
        return this.countries; // Call the sorting function
      }

      this.currentPage = 1;

      // Sort the search results based on the current sorting order
      return searchResults.sort((a, b) => {
        const nameA = a.name.official.toLowerCase();
        const nameB = b.name.official.toLowerCase();
        const sortOrderFactor = this.sortOrderIcon === 'asc' ? 1 : -1;

        return sortOrderFactor * nameA.localeCompare(nameB);
      });
    },
    totalPages() {
      return Math.ceil(this.searchAndSortCountries.length / this.itemsPerPage);
    },
    paginatedCountries() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.searchAndSortCountries.slice(start, end);
    },
    showPreviousButton() {
      return this.currentPage !== 1;
    },
    showNextButton() {
      return this.currentPage !== this.totalPages;
    },
  },

};	
</script>

<template>
  <div class="h-screen py-6 flex flex-col items-center text-center">
    <!-- Title -->
    <h1 class="text-black text-4xl font-bold mb-4">Country Lists</h1>

    <!-- Add div for search country by name -->
    <div class="mb-4 flex items-center">
      <label for="search" class="sr-only">Search Country by name</label>
      <input v-model="searchQuery" type="search" id="search" placeholder="Search by Country Name"
        class="py-2 px-4 border-2 border-black rounded w-64 ml-auto" />
    </div>

    <div class="w-11/12 h-fit overflow-y-auto overflow-x-auto relative shadow-md sm:rounded-lg">
      <table class="w-full border border-collapse">
        <thead class="h-full sticky top-[-2px] bg-gray-200">
          <tr class="bg-gray-200">
            <th class="py-2 px-4">NO</th>
            <th class="py-2 px-4">Flags</th>
            <th class="py-2 px-4">
              <button @click="toggleSortOrder">
                Country Name
                <SortIcon v-if="sortOrderIcon === 'default'" class="w-4 h-4 ml-10 inline" />
                <SortAscIcon v-else-if="sortOrderIcon === 'asc'" class="w-4 h-4 ml-10 inline" />
                <SortDescIcon v-else-if="sortOrderIcon === 'desc'" class="w-4 h-4 ml-10 inline" />
              </button>
            </th>
            <th class="py-2 px-4">2-charactesr Country Code</th>
            <th class="py-2 px-4">3-characters Country Code</th>
            <th class="w-36 py-2 px-4">Native Country Name</th>
            <th class="w-36 py-2 px-4">Alternative Country Name</th>
            <th class="py-2 px-4">Country Calling Codes</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(country, index) in paginatedCountries" :key="country.cca2" class="border-t">
            <!-- NO -->
            <td class="py-2 px-4">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
            <!-- Flags -->
            <td class="mt-6 flex justify-center items-center py-2 px-4 border-2 border-black p-2 my-2">
              <img :src="country.flags.png" alt="Flag" class="w-fit h-fit object-cover rounded mb-2" />
            </td>
            <!-- Country Name -->
            <td class="py-2 px-4">
              <!-- Open the modal on country name click -->
              <button @click="showCountryModal(country)" class="text-black hover:text-blue-500">
                {{ country.name.official }}
              </button>
            </td>
            <!-- 2-characters Country Code -->
            <td class="py-2 px-4">{{ country.cca2 }}</td>
            <!-- 3-characters Country Code -->
            <td class="py-2 px-4">{{ country.cca3 }}</td>
            <!-- Native Country Name -->
            <td class="w-36 py-2 px-4">
              <div v-for="(nativeName, langCode) in country.name.nativeName" :key="langCode">
                <p>{{ langCode }}: {{ nativeName.official }}, {{ nativeName.common }}</p>
              </div>
            </td>
            <!-- Alternative Country Name -->
            <td class="w-10 py-2 px-4" v-if="country.altSpellings && country.altSpellings.length > 0">
              <div class="p-2 flex flex-col align-items-left justify-start text-left">
                <p>{{ country.altSpellings.join(", ") }}</p>
              </div>
            </td>
            <!-- Country Calling Codes -->
            <td class="py-2 px-4">{{ formatCountryId(country.idd) }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <!-- Pagination -->
    <div class="flex justify-center items-center mt-4">
      <button v-if="showPreviousButton" @click="prevPage" :disabled="currentPage === 1"
        class="
            text-white bg-gradient-to-r from-blue-500 via-blue-600 to-blue-700 hover:bg-gradient-to-br hover:text-black
            focus:ring-blue-300 dark:focus:ring-blue-800 font-medium rounded-lg text-sm text-center px-4 py-2 ml-2 shadow-md">
        Previous
      </button>

      <!-- Display a block of numbers as buttons -->
      <template v-for="page in totalPages">
        <button @click="currentPage = page" :class="{ 'bg-blue-500 text-white': currentPage === page }"
          class="px-4 py-2 mx-1 hover:bg-blue-300 shadow-md hover:text-black border-2 rounded-lg">{{ page }}</button>
      </template>

      <button v-if="showNextButton" @click="nextPage" :disabled="currentPage === totalPages"
        class="
            text-white bg-gradient-to-r from-blue-500 via-blue-600 to-blue-700 hover:bg-gradient-to-br hover:text-black
            focus:ring-blue-300 dark:focus:ring-blue-800 font-medium rounded-lg text-sm text-center px-4 py-2 ml-2 shadow-md">
        Next
      </button>
    </div>
  </div>

  <!-- Modal -->
  <CountryDetailModal v-if="selectedCountry" :country="selectedCountry" @closeModal="closeCountryModal" />
</template>