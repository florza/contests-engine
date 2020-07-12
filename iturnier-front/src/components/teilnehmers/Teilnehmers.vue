<template>
  <div class="max-w-md m-auto py-10">
    <div class="text-red" v-if="error">{{ error }}</div>
    <h3 class="font-mono font-regular text-3xl mb-4">Add a new teilnehmer</h3>
    <form action="" @submit.prevent="addTeilnehmer">
      <div class="mb-6">
        <label for="teilnehmer_title" class="label">Title</label>
        <input
          id="teilnehmer_title"
          class="input"
          autofocus autocomplete="off"
          placeholder="Type a teilnehmer name"
          v-model="newTeilnehmer.title" />
      </div>

      <div class="mb-6">
        <label for="teilnehmer_year" class="label">Year</label>
        <input
          id="teilnehmer_year"
          class="input"
          autofocus autocomplete="off"
          placeholder="Year"
          v-model="newTeilnehmer.year"
        />
       </div>

      <div class="mb-6">
        <label for="turnier" class="label">Turnier</label>
        <select id="turnier" class="select" v-model="newTeilnehmer.turnier">
          <option disabled value="">Select an turnier</option>
          <option :value="turnier.id" v-for="turnier in turniers" :key="turnier.id">{{ turnier.name }}</option>
        </select>
        <p class="pt-4">Don't see a Turnier? <router-link class="text-grey-darker underline" to="/turniers">Create one</router-link></p>
       </div>

      <input type="submit" value="Add Teilnehmer" class="font-sans font-bold px-4 rounded cursor-pointer no-underline bg-green hover:bg-green-dark block w-full py-4 text-white items-center justify-center" />
    </form>

    <hr class="border border-grey-light my-6" />

    <ul class="list-reset mt-4">
      <li class="py-4" v-for="teilnehmer in teilnehmers" :key="teilnehmer.id" :teilnehmer="teilnehmer">

        <div class="flex items-center justify-between flex-wrap">
          <div class="flex-1 flex justify-between flex-wrap pr-4">
            <p class="block font-mono font-semibold flex items-center">
              <svg class="fill-current text-indigo w-6 h-6 mr-2" viewBox="0 0 24 24" width="24" height="24"><title>teilnehmer vinyl</title><path d="M23.938 10.773a11.915 11.915 0 0 0-2.333-5.944 12.118 12.118 0 0 0-1.12-1.314A11.962 11.962 0 0 0 12 0C5.373 0 0 5.373 0 12s5.373 12 12 12 12-5.373 12-12c0-.414-.021-.823-.062-1.227zM12 16a4 4 0 1 1 0-8 4 4 0 0 1 0 8zm0-5a1 1 0 1 0 0 2 1 1 0 0 0 0-2z" ></path></svg>
              {{ teilnehmer.title }} &mdash; {{ teilnehmer.year }}
            </p>
            <p class="block font-mono font-semibold">{{ getTurnier(teilnehmer) }}</p>
          </div>
          <button class="bg-transparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 mr-2 rounded"
          @click.prevent="editTeilnehmer(teilnehmer)">Edit</button>

          <button class="bg-transparent text-sm hover:bg-red text-red hover:text-white no-underline font-bold py-2 px-4 rounded border border-red"
         @click.prevent="removeTeilnehmer(teilnehmer)">Delete</button>
        </div>

        <div v-if="teilnehmer == editedTeilnehmer">
          <form action="" @submit.prevent="updateTeilnehmer(teilnehmer)">
            <div class="mb-6 p-4 bg-white rounded border border-grey-light mt-4">

              <div class="mb-6">
                <label class="label">Title</label>
                <input class="input" v-model="teilnehmer.title" />
              </div>

              <div class="mb-6">
                <label class="label">Year</label>
                <input class="input" v-model="teilnehmer.year" />
              </div>

              <div class="mb-6">
                <label class="label">Turnier</label>
                <select id="turnier" class="select" v-model="teilnehmer.turnier">
                  <option :value="turnier.id" v-for="turnier in turniers" :key="turnier.id">{{ turnier.name }}</option>
                </select>
              </div>

              <input type="submit" value="Update" class="bg-transparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 mr-2 rounded">
            </div>
          </form>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'Teilnehmers',
  data () {
    return {
      turniers: [],
      teilnehmers: [],
      newTeilnehmer: [],
      error: '',
      editedTeilnehmer: ''
    }
  },
  created () {
    if (!localStorage.signedIn) {
      this.$router.replace('/')
    } else {
      this.$http.secured.get('/api/v1/teilnehmers')
        .then(response => { this.teilnehmers = response.data })
        .catch(error => this.setError(error, 'Something went wrong'))

      this.$http.secured.get('/api/v1/turniers')
        .then(response => { this.turniers = response.data })
        .catch(error => this.setError(error, 'Something went wrong'))
    }
  },
  methods: {
    setError (error, text) {
      this.error = (error.response && error.response.data && error.response.data.error) || text
    },
    getTurnier (teilnehmer) {
      const teilnehmerTurnierValues = this.turniers.filter(turnier => turnier.id === teilnehmer.turnier_id)
      let turnier

      teilnehmerTurnierValues.forEach(function (element) {
        turnier = element.name
      })

      return turnier
    },
    addTeilnehmer () {
      const value = this.newTeilnehmer
      if (!value) {
        return
      }
      this.$http.secured.post('/api/v1/teilnehmers/', { teilnehmer: { title: this.newTeilnehmer.title, year: this.newTeilnehmer.year, turnier_id: this.newTeilnehmer.turnier } })

        .then(response => {
          this.teilnehmers.push(response.data)
          this.newTeilnehmer = ''
        })
        .catch(error => this.setError(error, 'Cannot create teilnehmer'))
    },
    removeTeilnehmer (teilnehmer) {
      this.$http.secured.delete(`/api/v1/teilnehmers/${teilnehmer.id}`)
        .then(response => {
          this.teilnehmers.splice(this.teilnehmers.indexOf(teilnehmer), 1)
        })
        .catch(error => this.setError(error, 'Cannot delete teilnehmer'))
    },
    editTeilnehmer (teilnehmer) {
      this.editedTeilnehmer = teilnehmer
    },
    updateTeilnehmer (teilnehmer) {
      this.editedTeilnehmer = ''
      this.$http.secured.patch(`/api/v1/teilnehmers/${teilnehmer.id}`, { teilnehmer: { title: teilnehmer.title, year: teilnehmer.year, turnier_id: teilnehmer.turnier } })
        .catch(error => this.setError(error, 'Cannot update teilnehmer'))
    }
  }
}
</script>
