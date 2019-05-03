<template>
  <div v-if="status=='published'" class="course_card" :class="user_card_class">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{ course.role }}</p>
      <div v-if="course.role === 'Instructor'">
        <p :class="'licensed'" v-if="is_licensed" @click="toggleModalState">
          Licensed
        </p>
      </div>
    </div>

    <div class="overview bg-blue_2" v-if="is_staff">
      <h4>
        <a>Grading Status</a>
      </h4>
      <div>
        <p class="lining_figures">
          {{course.gradingStatus.ungraded}}
          <span>Ungraded</span>
        </p>
        <p class="lining_figures">
          {{course.gradingStatus.ready}}
          <span>Ready for release</span>
        </p>
        <p class="lining_figures">
          {{course.gradingStatus.resubmissions}}
          <span>Resubmissions</span>
        </p>
      </div>
    </div>

    <div class="overview bg-blue_2" v-else>
      <h4>Events &amp; Announcements</h4>
      <div>
        <p class="lining_figures">
            {{course.eventCount}}
            <span>Events this week</span>
        </p>
        <p class="lining_figures">
            {{course.announcementCount}}
            <span>Unread announcements</span>
        </p>
      </div>
    </div>

    <div class="course_assignments">
      <h4>Upcoming Assignments</h4>
      <legend v-if="is_staff">
        <p>Planned</p>
        <p>Submitted</p>
      </legend>
      <div class="assignment" v-for="assignment in course.assignments">
        <div>
          <p>
            <a>{{assignment.name}}</a>
            <span v-if="assignment.dueDate">Due {{assignment.dueDate}}</span>
          </p>
        </div>
        <div v-if="is_staff">
          <p>{{assignment.planned}}</p>
          <p>{{assignment.submitted}}</p>
        </div>
        <div v-else>
          <p :class="assignment_status(assignment)">
            {{assignment_status(assignment)}}
          </p>
        </div>
      </div>
      <div class="empty" v-if="!course.assignments.length">
        <p v-if="is_staff"><em>There aren’t any assignments coming up for this course</em></p>
        <p v-else><em>You don’t have any assignments coming up for this course</em></p>
      </div>
    </div>

    <div class="button_box">
      <a class="button next" v-bind:href="course.url">View course</a>
    </div>

    <modalComponent :modalState="modalState" @close="toggleModalState" class="component_container">
      <template slot="heading">Set Course Status</template>
      <template slot="content">
        <h2>Set the status of {{ course.number }} {{ course.name }} {{ course.term.name }} {{ course.term.year }}</h2>
        <form>
          <div class="form_options">
            <input :id="'trial-' + course.id" v-model="licenseStatus" value="trial" :name="'license-' + course.id" type="radio">
            <label :for="'trial-' + course.id">Trial course</label>
          </div>
          <div class="form_options">
            <input checked="checked" :id="'license-' + course.id" v-model="licenseStatus" value="license" :name="'license-' + course.id" type="radio">
            <label :for="'license-' + course.id">Licensed course</label>
          </div>
          <br>
          <button class="action" type="button" @click="toggleCourseLicense(); toggleModalState()">Update status</button>
        </form>
      </template>
    </modalComponent>
  </div>

  <div v-else-if="status=='unpublished'" class="course_card unpublished" :class="user_card_class">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
    </h4>

    <div class="course_status">
      <p>{{course.role}}</p>
      <div>
        <p>Unpublished Course</p>
        <p :class="'licensed'" v-if="is_licensed" @click="toggleModalState">
          Licensed
        </p>
      </div>
    </div>

    <div>
      <a class="button next" v-bind:href="course.url">View course</a>
    </div>

    <modalComponent :modalState="modalState" @close="toggleModalState" class="component_container">
      <template slot="heading">Set Course Status</template>
      <template slot="content">
        <h2>Set the status of {{ course.number }} {{ course.name }} {{ course.term.name }} {{ course.term.year }}</h2>
        <form>
          <div class="form_options">
            <input type="radio" :id="'trial-' + course.id" v-model="licenseStatus" value="trial" :name="'course-' + course.id">
            <label :for="'trial-' + course.id">Trial course</label>
          </div>
          <div class="form_options">
            <input type="radio" :id="'license-' + course.id" v-model="licenseStatus" value="license" :name="'course-' + course.id">
            <label :for="'license-' + course.id">Licensed course</label>
          </div>
          <br>
          <button class="action" type="button" @click="toggleCourseLicense(); toggleModalState()">Update status</button>
        </form>
      </template>
    </modalComponent>
  </div>

  <div v-else-if="status=='past'" class="course_card past" :class="user_card_class">
    <h4>
      <span>{{ course.number }} {{ course.name }}</span>
      <span>{{ course.term.name }} {{ course.term.year }}</span>
    </h4>

    <div class="course_status">
      <p>{{course.role}}</p>
      <div>
        <p :class="'licensed'" v-if="is_licensed">
          Licensed
        </p>
      </div>
    </div>

    <div>
      <a class="button next" v-bind:href="course.url">View course</a>
    </div>
  </div>
</template>

<script lang='coffee'>`
module.exports = {
  name: 'course-card',
  props: ['course', 'status'],
  components: {
    modalComponent: () => VComponents.get('vue/components/modalComponent')
  },
  data() {
    return {
      modalState: false,
      licenseStatus: this.course.licensed ? "license" : "trial"
    }
  },
  computed: {
    is_staff() {
      return this.course.role === 'Instructor' || this.course.role === 'gsi';
    },
    user_card_class() {
      if( this.is_staff ){ return 'instructor' }
      else { return 'student'}
    },
    is_licensed() {
      return this.course.licensed
    }
  },
  methods: {
    toggleModalState(){
      this.modalState = !this.modalState
    },
    assignment_status(assignment){
      if (assignment.graded){ return "graded" }
      if (assignment.submitted){ return "submitted" }
      if (assignment.planned){ return "planned" }
    },
    toggleCourseLicense(){
      if (this.licenseStatus === "license"){this.$store.dispatch('licenseCourse', this.course.id)}
      if (this.licenseStatus === "trial"){this.$store.dispatch('unLicenseCourse', this.course.id)}
    }
  }
}
`</script>
