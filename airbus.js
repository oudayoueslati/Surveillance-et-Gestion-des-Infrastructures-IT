document.addEventListener('DOMContentLoaded', function() {
    const pcMap = document.getElementById('pcMap');

    const newArea = document.createElement('area');
    newArea.shape = 'rect';
    newArea.coords = '74,2,226,116'; 
    newArea.href = 'Pc5A.php';
    newArea.alt = 'PC 5A';
    pcMap.appendChild(newArea);
});

document.addEventListener('DOMContentLoaded', function() {
  loadPCs();

  document.getElementById('add-pc').addEventListener('click', function() {
      let pcNumber = prompt('Entrez le numéro du PC:');
      if (!pcNumber) {
          alert('Aucun numéro fourni. Opération annulée.');
          return;
      }

      addPC(pcNumber.trim()); l
      showMessage('PC ajouté avec succès');
  });

  document.getElementById('remove-pc').addEventListener('click', function() {
      let selectedPC = document.querySelector('.pc.selected');
      if (selectedPC) {
          selectedPC.remove();
          savePCs();
          showMessage('PC supprimé avec succès');
      } else {
          alert('Veuillez sélectionner un PC à supprimer.');
      }
  });

  interact('.pc')
      .draggable({
          inertia: true,
          autoScroll: true,
          modifiers: [
              interact.modifiers.restrictRect({
                  restriction: 'parent',
                  endOnly: true
              })
          ],
          listeners: {
              move: dragMoveListener,
          }
      });

  function dragMoveListener(event) {
      let target = event.target;
      let x = (parseFloat(target.getAttribute('data-x')) || 0) + event.dx;
      let y = (parseFloat(target.getAttribute('data-y')) || 0) + event.dy;

      target.style.transform = `translate(${x}px, ${y}px)`;
      target.setAttribute('data-x', x);
      target.setAttribute('data-y', y);
  }

  interact('.pc').on('mousedown', function(event) {
      event.currentTarget.classList.add('selected');
  });

  interact('.pc').on('mouseup', function(event) {
      savePCs();
  });
});

function addPC(pcNumber) {
  let pcElement = document.createElement('div');
  pcElement.className = 'pc';
  pcElement.textContent = pcNumber;
  pcElement.style.position = 'absolute';
  pcElement.style.left = '50px'; 
  pcElement.style.top = '50px';  

  document.getElementById('image-container').appendChild(pcElement);
  savePCs();
}

function savePCs() {
  let pcs = [];
  document.querySelectorAll('.pc').forEach(pc => {
      let pcPosition = {
          left: pc.style.left,
          top: pc.style.top,
          number: pc.textContent.trim() 
      };
      pcs.push(pcPosition);
  });
  localStorage.setItem('pcs', JSON.stringify(pcs));
}

function loadPCs() {
  let pcs = JSON.parse(localStorage.getItem('pcs')) || [];
  pcs.forEach(pcPosition => {
      let pcElement = document.createElement('div');
      pcElement.className = 'pc';
      pcElement.textContent = pcPosition.number; 
      pcElement.style.position = 'absolute';
      pcElement.style.left = pcPosition.left;
      pcElement.style.top = pcPosition.top;

      document.getElementById('image-container').appendChild(pcElement);
  });
}

function showMessage(message) {
  let messageElement = document.getElementById('message');
  messageElement.textContent = message;
  messageElement.classList.remove('hidden');
  messageElement.classList.add('show');
  setTimeout(() => {
      messageElement.classList.remove('show');
      messageElement.classList.add('hidden');
  }, 2000);
}
