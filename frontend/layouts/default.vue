<template>
  <v-app>
    <v-navigation-drawer
      :mini-variant="miniVariant"
      :clipped="clipped"
      v-model="drawer"
      class="left-sidebar"
      width="220"
      fixed
      app
      dark
    >
      <v-list>
        <v-list-tile
          router
          :to="item.to"
          :key="i"
          v-for="(item, i) in items"
          exact
        >
          <v-list-tile-action>
            <v-icon v-html="item.icon"></v-icon>
          </v-list-tile-action>
          <v-list-tile-content>
            <v-list-tile-title v-text="item.title"></v-list-tile-title>
          </v-list-tile-content>
        </v-list-tile>
      </v-list>
    </v-navigation-drawer>
    <v-toolbar fixed app color="white" :clipped-left="clipped">
      <nuxt-link class="logo" to="/"></nuxt-link>
      <v-toolbar-side-icon @click="drawer = !drawer"></v-toolbar-side-icon>
      <v-spacer></v-spacer>
      <v-btn icon>
        <v-icon>search</v-icon>
      </v-btn>
      <v-avatar size="36px">
        <img src="https://www.gravatar.com/avatar/52637be90c1a6dde63624938964c7919?s=150&d=identicon" alt="John">
      </v-avatar>
    </v-toolbar>
    <v-content>
      <nuxt />
    </v-content>
    <v-navigation-drawer
      temporary
      :right="right"
      v-model="rightDrawer"
      fixed
    >
      Lorem ipsum dolor sit amet consectetur, adipisicing elit. Incidunt quibusdam laboriosam corrupti repudiandae a dolor quo molestiae suscipit officiis. Harum obcaecati voluptates odio consectetur consequatur fugit quae cumque commodi excepturi.
    </v-navigation-drawer>
    <v-footer :fixed="fixed" app>
      <span>&copy; 2018 <a href="https://consensys.net/">ConsenSys</a>. All Rights Reserved.</span>
    </v-footer>
  </v-app>
</template>

<script>
  export default {
    data() {
      return {
        clipped: true,
        drawer: true,
        fixed: false,
        items: [
          { icon: 'dashboard', title: 'Dashboard', to: '/dashboard' },
          { icon: 'devices', title: 'Websites', to: '/websites' },
          { icon: 'picture_in_picture_alt', title: 'Campaigns', to: '/campaigns' },
          { icon: 'art_track', title: 'Ad Creatives', to: '/ad-creatives' },
          { icon: 'style', title: 'Templates', to: '/templates' },
          { icon: 'people', title: 'Users', to: '/users' },
          { icon: 'person_outline', title: 'Profile', to: '/profile' }
        ],
        miniVariant: false,
        right: true,
        rightDrawer: false,
        title: 'CodeFund'
      }
    }
  }
</script>

<style>
  .logo {
    width: 184px;
    height: 60px;
    padding: .5rem 1rem;
    margin-right: 18px;
    display: inline-block;
    background-image: url(~assets/images/codefund-logo.png);
    background-repeat: no-repeat;
    background-position: 50%;
    background-size: 150px auto;
  }
</style>

