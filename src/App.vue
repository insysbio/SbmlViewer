<template>
  <div id="app">
    <ToolBar></ToolBar>
    <ModelArea></ModelArea>
  </div>
</template>

<script>
import ToolBar from './components/tool-bar/tool-bar.vue'
import ModelArea from './components/model-area/model-area.vue'
export default {
  name: 'App',
  components: {
    ToolBar,
    ModelArea
  }
}
</script>

<style>
html {
  overflow: hidden;
}

</style>
