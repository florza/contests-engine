<template>
  <div class="max-w-md m-auto py-10">
    <div class="text-red" v-if="error">{{ error }}</div>
    <h3 class="font-mono font-regular text-3xl mb-4">Add a new turnier</h3>
    <form action="" @submit.prevent="addTurnier">
      <div class="mb-6">
        <input class="input"
          autofocus autocomplete="off"
          placeholder="Turniername"
          v-model="newTurnier.name" />
      </div>
      <input type="submit" value="Add Turnier" class="font-sans font-bold px-4 rounded cursor-pointer no-underline bg-green hover:bg-green-dark block w-full py-4 text-white items-center justify-center" />
    </form>

    <hr class="border border-grey-light my-6" />

    <ul class="list-reset mt-4">
      <li class="py-4" v-for="turnier in turniers" :key="turnier.id" :turnier="turnier">

        <div class="flex items-center justify-between flex-wrap">
          <p class="block flex-1 font-mono font-semibold flex items-center ">
            <svg class="fill-current text-indigo w-6 h-6 mr-2" viewBox="0 0 20 20" width="20" height="20"><title>music turnier</title><path d="M15.75 8l-3.74-3.75a3.99 3.99 0 0 1 6.82-3.08A4 4 0 0 1 15.75 8zm-13.9 7.3l9.2-9.19 2.83 2.83-9.2 9.2-2.82-2.84zm-1.4 2.83l2.11-2.12 1.42 1.42-2.12 2.12-1.42-1.42zM10 15l2-2v7h-2v-5z"></path></svg>
            {{ turnier.name }}
          </p>

          <button class="bg-tranparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 mr-2 rounded"
          @click.prevent="editTurnier(turnier)">Edit</button>

          <button class="bg-transprent text-sm hover:bg-red text-red hover:text-white no-underline font-bold py-2 px-4 rounded border border-red"
         @click.prevent="removeTurnier(turnier)">Delete</button>
        </div>

        <div v-if="turnier == editedTurnier">
          <form action="" @submit.prevent="updateTurnier(turnier)">
            <div class="mb-6 p-4 bg-white rounded border border-grey-light mt-4">
              <input class="input" v-model="turnier.name" />
              <input type="submit" value="Update" class=" my-2 bg-transparent text-sm hover:bg-blue hover:text-white text-blue border border-blue no-underline font-bold py-2 px-4 rounded cursor-pointer">
            </div>
          </form>
        </div>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'Turniers',
  data () {
    return {
      turniers: [],
      newTurnier: [],
      error: '',
      editedTurnier: ''
    }
  },
  created () {
    if (!localStorage.signedIn) {
      this.$router.replace('/')
    } else {
      this.$http.secured.get('/api/v1/turniers')
        .then(response => { this.turniers = response.data })
        .catch(error => this.setError(error, 'Something went wrong'))
    }
  },
  methods: {
    setError (error, text) {
      this.error = (error.response && error.response.data && error.response.data.error) || text
    },
    addTurnier () {
      const value = this.newTurnier
      if (!value) {
        return
      }
      this.$http.secured.post('/api/v1/turniers/', { turnier: { name: this.newTurnier.name } })

        .then(response => {
          this.turniers.push(response.data)
          this.newTurnier = ''
        })
        .catch(error => this.setError(error, 'Cannot create turnier'))
    },
    removeTurnier (turnier) {
      this.$http.secured.delete(`/api/v1/turniers/${turnier.id}`)
        .then(response => {
          this.turniers.splice(this.turniers.indexOf(turnier), 1)
        })
        .catch(error => this.setError(error, 'Cannot delete turnier'))
    },
    editTurnier (turnier) {
      this.editedTurnier = turnier
    },
    updateTurnier (turnier) {
      this.editedTurnier = ''
      this.$http.secured.patch(`/api/v1/turniers/${turnier.id}`, { turnier: { title: turnier.name } })
        .catch(error => this.setError(error, 'Cannot update turnier'))
    }
  }
}
</script>
