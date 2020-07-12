<template>
  <b-container>
    <b-row>
      <b-row cols="8">

        <b-link href="/" >
          iTurnier
        </b-link>
      </b-row>
      <b-row cols="8">
        <div>
          <b-nav pills fill>
            <b-nav-item to="/" v-if="!signedIn()">
              Sign in
            </b-nav-item>
            <b-nav-item to="/signup" v-if="!signedIn()">
              Sign Up
            </b-nav-item>
            <b-nav-item to="/turniers" v-if="signedIn()">
              Turniere
            </b-nav-item>
            <b-nav-item to="/teilnehmers" v-if="signedIn()">
              Teilnehmer
            </b-nav-item>
          </b-nav>
        </div>
        <div>
          <a href="#" @click.prevent="signOut" class="link-grey px-2 no-underline" v-if="signedIn()">Sign out</a>
        </div>
      </b-row>
    </b-row>
  </b-container>
</template>

<script>
export default {
  name: 'Header',
  created () {
    this.signedIn()
  },
  methods: {
    setError (error, text) {
      this.error = (error.response && error.response.data && error.response.data.error) || text
    },
    signedIn () {
      return localStorage.signedIn
    },
    signOut () {
      this.$http.secured.delete('/signin')
        .then(response => {
          delete localStorage.csrf
          delete localStorage.signedIn
          this.$router.replace('/')
        })
        .catch(error => this.setError(error, 'Cannot sign out'))
    }
  }
}
</script>
