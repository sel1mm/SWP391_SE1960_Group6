(function(){
  function showToast(message, type){
    var container = document.querySelector('.crm-toast');
    if(!container){
      container = document.createElement('div');
      container.className = 'crm-toast';
      document.body.appendChild(container);
    }
    var alert = document.createElement('div');
    alert.className = 'alert alert-' + (type || 'success') + ' alert-dismissible fade show';
    alert.setAttribute('role','alert');
    alert.innerHTML = message + '<button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>';
    container.appendChild(alert);
    setTimeout(function(){
      if(alert && alert.parentNode){ alert.parentNode.removeChild(alert); }
    }, 4000);
  }

  function updateStatus(taskId, newStatus, comment){
    return fetch((window.appContext || '') + '/api/technician/tasks/' + encodeURIComponent(taskId) + '/status', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ status: newStatus, comment: comment || '' })
    }).then(function(r){ return r.json(); })
    .then(function(json){
      if(json && json.success){
        var badge = document.querySelector('[data-task-status-badge="' + taskId + '"]');
        if(badge){
          badge.textContent = json.status;
          badge.className = 'badge ' + statusToBadgeClass(json.status);
        }
        showToast('Status updated to ' + json.status, 'success');
      } else {
        showToast('Failed to update status', 'danger');
      }
      return json;
    })
    .catch(function(){ showToast('Network error while updating status', 'danger'); });
  }

  function statusToBadgeClass(status){
    var s = (status || '').toLowerCase();
    if(s === 'pending') return 'badge-status-pending';
    if(s === 'in progress') return 'badge-status-inprogress';
    if(s === 'completed') return 'badge-status-completed';
    if(s === 'on hold') return 'badge-status-onhold';
    return 'bg-secondary';
  }

  function ajaxSearchTasks(form){
    var formEl = typeof form === 'string' ? document.querySelector(form) : form;
    if(!formEl) return;
    var url = formEl.getAttribute('action') || (window.appContext || '') + '/technician/tasks';
    var params = new URLSearchParams(new FormData(formEl));
    fetch(url + '?' + params.toString(), { headers: { 'X-Requested-With': 'fetch' }})
      .then(function(r){ return r.text(); })
      .then(function(html){
        var parser = new DOMParser();
        var doc = parser.parseFromString(html, 'text/html');
        var newTbody = doc.querySelector('#tasks-table-body');
        var tbody = document.querySelector('#tasks-table-body');
        if(newTbody && tbody){ tbody.innerHTML = newTbody.innerHTML; }
      });
  }

  window.TechnicianUI = {
    updateStatus: updateStatus,
    statusToBadgeClass: statusToBadgeClass,
    ajaxSearchTasks: ajaxSearchTasks,
    showToast: showToast
  };
})();


