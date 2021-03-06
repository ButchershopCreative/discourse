import ModalFunctionality from 'discourse/mixins/modal-functionality';
import Controller from 'discourse/controllers/controller';

export default Controller.extend(ModalFunctionality, {

  needs: ["adminBackupsLogs"],

  _startBackup: function (withUploads) {
    var self = this;
    Discourse.User.currentProp("hideReadOnlyAlert", true);
    Discourse.Backup.start(withUploads).then(function() {
      self.get("controllers.adminBackupsLogs").clear();
      self.send("backupStarted");
    });
  },

  actions: {

    startBackup: function () {
      return this._startBackup();
    },

    startBackupWithoutUpload: function () {
      return this._startBackup(false);
    },

    cancel: function () {
      this.send("closeModal");
    }

  }

});
