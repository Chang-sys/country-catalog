<script>
export default {
  data() {
    return {
      countries: [],
      searchQuery: "",
      sortKey: "",
      sortDirection: "asc",
      currentPage: 1,
      itemsPerPage: 25,
    };
  },
  mounted() {
    console.log("CountryList.vue component mounted");
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
    sortBy(key) {
      this.sortKey = key;
      this.sortDirection = this.sortDirection === "asc" ? "desc" : "asc";
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
      return this.countries.filter((country) => {
        return country.name.official
          .toLowerCase()
          .includes(this.searchQuery.toLowerCase());
      });
    },
    sortedCountries() {
      if (!this.sortKey || this.filteredCountries.length === 0) {
        // Return unsorted countries if sortKey is not set or filteredCountries is empty
        return this.filteredCountries;
      }

      const sorted = this.filteredCountries.slice().sort((a, b) => {
        const keyA = a[this.sortKey] || ""; // Handle undefined key
        const keyB = b[this.sortKey] || ""; // Handle undefined key

        const modifier = this.sortDirection === "desc" ? -1 : 1;
        return modifier * keyA.localeCompare(keyB);
      });

      return sorted;
    },
    totalPages() {
      return Math.ceil(this.sortedCountries.length / this.itemsPerPage);
    },
    paginatedCountries() {
      const start = (this.currentPage - 1) * this.itemsPerPage;
      const end = start + this.itemsPerPage;
      return this.sortedCountries.slice(start, end);
    },
  },
};
</script>

<template>
  <div class="py-6 flex flex-col items-center text-center">
    <h1 class="text-black text-6xl font-bold mb-4">Country Lists</h1>

    <!-- add div for search country by name -->
    <div class="mb-4 flex items-center">
      <label for="search" class="sr-only">Search Country by name</label>
      <input v-model="searchQuery" type="text" id="search" placeholder="Search by Country Name"
        class="py-2 px-4 border-2 border-black rounded w-64 ml-auto" />
    </div>

    <table class="w-full border border-collapse">
      <thead class="sticky top-0 bg-gray-200 z-10">
        <tr class="bg-gray-200">
          <th class="py-2 px-4">NO</th>
          <th class="py-2 px-4">Flags</th>
          <th class="py-2 px-4">Country Name</th>
          <th class="py-2 px-4">2-character Country Code</th>
          <th class="py-2 px-4">3-character Country Code</th>
          <th class="w-36 py-2 px-4">Native Country Name</th>
          <th class="w-36 py-2 px-4">Alternative Country Name</th>
          <th class="py-2 px-4">Country Calling Codes</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="(country, index) in paginatedCountries" :key="country.cca2" class="border-t">
          <td class="py-2 px-4">{{ (currentPage - 1) * itemsPerPage + index + 1 }}</td>
          <td class="py-2 px-4">
            <img :src="country.flags.png" alt="Flag" class="w-full max-h-32 object-cover rounded mb-2" />
          </td>
          <td class="py-2 px-4">{{ country.name.official }}</td>
          <td class="py-2 px-4">{{ country.cca2 }}</td>
          <td class="py-2 px-4">{{ country.cca3 }}</td>
          <td class="w-36 py-2 px-4 flex flex-col align-items-left justify-start text-left" v-if="country.name.nativeName"
            colspan="2">
            <div v-for="(names, langCode) in country.name.nativeName" :key="langCode + '-official'">
              <div v-if="isUnique(names.common)">
                <div class="p-2">
                  <p>{{ names.official }}</p>
                </div>
                <div class="p-2 mt-2">
                  <p>{{ names.common }}</p>
                </div>
              </div>
            </div>
          </td>
          <td class="w-10 py-2 px-4" v-if="country.altSpellings && country.altSpellings.length > 0">
            <div class="p-2 flex flex-col align-items-left justify-start text-left">
              <p>{{ country.altSpellings.join(", ") }}</p>
            </div>
          </td>
          <td class="py-2 px-4">{{ country.idd.root + (country.idd.suffixes ? country.idd.suffixes.join('') : '') }}</td>
        </tr>
      </tbody>
    </table>

    <!-- Pagination -->
    <div class="flex justify-center items-center mt-4">
      <button @click="prevPage" :disabled="currentPage === 1" class="px-4 py-2 bg-blue-500 text-white mr-2">Prev</button>

      <!-- Display a block of numbers as buttons -->
      <template v-for="page in totalPages">
        <button @click="currentPage = page" :class="{ 'bg-blue-500 text-white': currentPage === page }"
          class="px-4 py-2 mx-1 hover:bg-blue-300 hover:text-black">{{ page }}</button>
      </template>

      <button @click="nextPage" :disabled="currentPage === totalPages"
        class="px-4 py-2 bg-blue-500 text-white ml-2">Next</button>
    </div>

  </div>
</template>
