<script>
// Import Fuzzysort
import fuzzysort from 'fuzzysort';
import SortIcon from './icons/SortIcon.vue';
// Icon filter Asc from A to Z or 0 to 9
import SortAscIcon from './icons/SortAscIcon.vue';
// Icon filter Desc from Z to A or 9 to 0
import SortDescIcon from './icons/SortDescIcon.vue';

export default {
  data() {
    return {
      countries: [],
      DataCountries: [],
      searchQuery: "",
      sortOrder: "asc",
      sortOrderIcon: 'default',
      currentPage: 1,
      itemsPerPage: 25,
    };
  },
  components: {
    SortIcon,
    SortAscIcon,
    SortDescIcon,
  },
  mounted() {
    console.log("API mounted");
    this.fetchCountries();
  },
  methods: {
    async fetchCountries() {
      try {
        const response = await fetch("https://restcountries.com/v3.1/all");
        const data = await response.json();
        this.countries = data;
        this.DataCountries = data;
      } catch (error) {
        console.error("Error fetching countries:", error);
      }
    },
    toggleSortOrder() {
      this.sortOrderIcon = this.sortOrderIcon === 'asc' ? 'desc' : 'asc';
      this.sortedCountries(); // Call the sorting function when the button is clicked
    },
    sortedCountries() {
      const sortOrderFactor = this.sortOrderIcon === 'asc' ? 1 : -1;

      this.DataCountries.sort((a, b) =>
        sortOrderFactor * a.name.official.localeCompare(b.name.official)
      );
    },
    sortedCountries() {

      const sortOrderFactor = this.sortOrderIcon === 'asc' ? 1 : -1;

      return this.countries.sort((a, b) => {
        const nameA = a.name.official.toLowerCase(); // Ensure consistent case
        const nameB = b.name.official.toLowerCase();

        return sortOrderFactor * nameA.localeCompare(nameB);
      });
    },

    formatCountryId(idd) {
      const root = idd.root || ''; // Handle the case when root is undefined
      const suffixes = idd.suffixes ? idd.suffixes.join('') : '';
      const fullString = root + suffixes;

      if (fullString.length > 30) {
        // If the string is longer than 30 characters, truncate it and add "..."
        return fullString.substring(0, 30) + '...';
      } else if (fullString.length > 7) {
        // If the string is longer than 6 characters, add a comma every 6 characters
        const chunks = [];
        for (let i = 0; i < fullString.length; i += 6) {
          chunks.push(fullString.substring(i, i + 6));
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
  },
  computed: {

    filteredCountries() {
      // Use Fuzzysort to search by country name
      const searchResults = fuzzysort
        .go(this.searchQuery, this.countries, { key: 'name.official' })
        .map(result => result.obj);

      // If no search query or no matching results, return the original countries
      if (!this.searchQuery || searchResults.length === 0) {
        return this.sortedCountries(); // Call the sorting function
      }

      // Sort the search results based on the selected order
      const sortOrderFactor = this.sortOrderIcon === 'asc' ? 1 : -1;
      searchResults.sort((a, b) =>
        sortOrderFactor * a.name.official.localeCompare(b.name.official)
      );

      return searchResults;
    },

    totalPages() {
      return Math.ceil(this.filteredCountries.length / this.itemsPerPage);
    },
    paginatedCountries() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.filteredCountries.slice(start, end);
    },
  },
};
</script>

<template>
  <div class="h-screen py-6 flex flex-col items-center text-center">
    <h1 class="text-black text-4xl font-bold mb-4">Country Lists</h1>

    <!-- add div for search country by name -->
    <div class="mb-4 flex items-center">
      <label for="search" class="sr-only">Search Country by name</label>
      <input v-model="searchQuery" type="text" id="search" placeholder="Search by Country Name"
        class="py-2 px-4 border-2 border-black rounded w-64 ml-auto" />
    </div>

    <div class="mt-0 w-11/12 h-fit overflow-y-auto overflow-x-auto relative shadow-md sm:rounded-lg">
      <table class="w-full border border-collapse">
        <thead class="h-fit sticky top-0 bg-gray-200 z-10">
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
            <td class="w-48 py-2 px-3 flex justify-center items-center">
              <img :src="country.flags.png" alt="Flag" class="w-fit h-fit object-cover rounded mb-2" />
            </td>
            <!-- Country Name -->
            <td class="py-2 px-4">{{ country.name.official }}</td>
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
      <button @click="prevPage" :disabled="currentPage === 1"
        class="px-4 py-2 bg-blue-500 text-white mr-2 rounded-lg shadow-md">
        Previous</button>

      <!-- Display a block of numbers as buttons -->
      <template v-for="page in totalPages">
        <button @click="currentPage = page" :class="{ 'bg-blue-500 text-white': currentPage === page }"
          class="px-4 py-2 mx-1 hover:bg-blue-300 shadow-md hover:text-black border-2 rounded-lg">{{ page }}</button>
      </template>

      <button @click="nextPage" :disabled="currentPage === totalPages"
        class="px-4 py-2 bg-blue-500 text-white ml-2 rounded-lg shadow-md">Next</button>
    </div>

  </div>
</template>
