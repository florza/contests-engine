import Vue from 'vue'
import Router from 'vue-router'
import Signin from '@/components/Signin.vue'
import Signup from '@/components/Signup.vue'
import Turniers from '@/components/turniers/Turniers.vue'
import Teilnehmers from '@/components/teilnehmers/Teilnehmers.vue'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/turniers',
      name: 'Turniers',
      component: Turniers
    },
    {
      path: '/teilnehmers',
      name: 'Teilnehmers',
      component: Teilnehmers
    },
    {
      path: '/',
      name: 'Signin',
      component: Signin
    },
    {
      path: '/signup',
      name: 'Signup',
      component: Signup
    }
  ]
})
