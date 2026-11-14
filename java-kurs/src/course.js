/* Java-Kurs – die ganze Kursseite: Navigation, gemeinsamer Speicher (Account über db, sonst Browser),
 * Startseite mit Lernpfad und Ziel, Lektionen, Challenges, Notenbuch und Spielplatz. */
(function () {
  'use strict';
  const JK = window.JK, C = window.COURSE;
  const { $, $$, esc, md, toast, GRADE_WORD, fmtTime } = JK.util;
  const LESSONS = C.lessons, CHAL = C.challenges;

  // ------------------------------------------------------------------ Zustand
  const KEY = 'javakurs:kurs';
  const S = { v: 1, lessons: {}, quizzes: {}, tasks: {}, openTask: null, last: null };
  try { const raw = localStorage.getItem(KEY); if (raw) Object.assign(S, JSON.parse(raw)); } catch (e) { /* kein Speicher */ }
  const store = { ref: null, writing: false, dirty: false, mode: 'local', note: 'Fortschritt wird nur in diesem Browser gespeichert.' };
  function persist() {
    try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) { /* egal */ }
    if (!store.ref) return;
    if (store.writing) { store.dirty = true; return; }
    store.writing = true;
    store.ref.set(JSON.parse(JSON.stringify(S))).catch(() => {}).finally(() => { store.writing = false; if (store.dirty) { store.dirty = false; persist(); } });
  }
  function merge(remote) {
    const before = JSON.stringify([S.tasks, S.quizzes, S.openTask, S.lessons]);
    S.tasks = Object.assign({}, remote.tasks || {}, S.tasks);
    S.quizzes = Object.assign({}, remote.quizzes || {}, S.quizzes);
    for (const [id, l] of Object.entries(remote.lessons || {})) { const mine = S.lessons[id] || (S.lessons[id] = { t: 0, done: false }); mine.t = Math.max(mine.t || 0, l.t || 0); mine.done = mine.done || !!l.done; }
    if (remote.openTask && !S.tasks[remote.openTask.id]) S.openTask = remote.openTask;
    if (S.openTask && S.tasks[S.openTask.id]) S.openTask = null;
    if (!S.last && remote.last) S.last = remote.last;
    return JSON.stringify([S.tasks, S.quizzes, S.openTask, S.lessons]) !== before;
  }
  async function initStore() {
    if (!window.claude || !window.claude.use) return;
    try {
      const user = await window.claude.use('user');
      const uid = user ? await user.id() : null;
      const db = uid ? await window.claude.use('db') : null;
      if (!db || !uid) return;
      store.ref = db.doc('data/users/' + uid + '/kurs'); store.mode = 'db';
      const timer = setTimeout(() => setNote('Dein Fortschritt kann gerade nicht geladen werden – er wird nachgeholt, sobald die Verbindung steht.'), 10000);
      let first = true;
      store.ref.onSnapshot(snap => {
        if (!snap.metadata.fromCache) clearTimeout(timer);
        if (snap.metadata.hasPendingWrites) return;
        let changed = false;
        if (snap.exists) changed = merge(snap.data());
        if (first) { first = false; persist(); }
        setNote('Fortschritt und Noten werden in deinem Account gespeichert – auf allen Geräten gleich.');
        if (changed) { try { localStorage.setItem(KEY, JSON.stringify(S)); } catch (e) { /* egal */ } refresh(); }
      }, () => { clearTimeout(timer); setNote('Fortschritt wird nur in diesem Browser gespeichert.'); });
    } catch (e) { /* lokal weiter */ }
  }
  function setNote(t) { store.note = t; $$('.store-note').forEach(el => (el.textContent = t)); }

  const ctx = {
    state: S, persist, count: LESSONS.length,
    ls: id => S.lessons[id] || (S.lessons[id] = { t: 0, done: false }),
    navigate: h => { if (location.hash === h) route(); else location.hash = h; },
    onChange: () => renderNav(),
  };

  // ------------------------------------------------------------------ Hilfen
  const allTasks = () => LESSONS.flatMap(L => JK.buildTimeline(L).steps.filter(s => s.task).map(s => ({ task: s.task, lesson: L })));
  const subOf = id => S.tasks[id] && S.tasks[id].result ? S.tasks[id] : null;
  const avgOf = ids => { const g = ids.map(subOf).filter(Boolean).map(s => s.result.note); return g.length ? g.reduce((a, b) => a + b, 0) / g.length : null; };
  const fmtAvg = a => a == null ? '–' : a.toFixed(1).replace('.', ',');
  function lessonProgress(L) {
    const { TOTAL } = JK.buildTimeline(L), ls = S.lessons[L.id];
    if (!ls) return 0;
    return ls.done ? 1 : Math.min(1, (ls.t || 0) / TOTAL);
  }

  // ------------------------------------------------------------------ Navigation
  const nav = $('#nav'), view = $('#view'), banner = $('#lockbar');
  function renderNav() {
    const h = location.hash || '#start';
    const tasks = allTasks().map(x => x.task.id).concat(CHAL.map(c => c.id));
    const avg = avgOf(tasks);
    nav.innerHTML = `
      <a class="brand" href="#start">☕ Java-Kurs</a>
      <div class="navlinks" role="list">
        <a role="listitem" href="#start" class="${h === '#start' ? 'on' : ''}">Start</a>
        ${LESSONS.map(L => { const p = lessonProgress(L); return `<a role="listitem" href="#lektion-${L.nr}" class="lpill ${h === '#lektion-' + L.nr ? 'on' : ''} ${p >= 1 ? 'done' : ''}" title="Lektion ${L.nr}: ${esc(L.title)}">${p >= 1 ? '✓' : L.nr}</a>`; }).join('')}
        <a role="listitem" href="#challenges" class="${/^#challenge/.test(h) ? 'on' : ''}">Challenges</a>
        <a role="listitem" href="#noten" class="${h === '#noten' ? 'on' : ''}">Notenbuch <b class="avgchip">${fmtAvg(avg)}</b></a>
        <a role="listitem" href="#spielplatz" class="${h === '#spielplatz' ? 'on' : ''}">Spielplatz</a>
      </div>`;
    const ot = S.openTask;
    banner.hidden = !ot || h === '#lektion-' + (ot && ot.nr);
    if (ot) banner.innerHTML = `<span>🔒 <b>Aufgabe offen:</b> „${esc(ot.title)}“ in Lektion ${ot.nr}. Alle Videos sind gesperrt, bis du abgibst.</span><a class="btn primary" href="#lektion-${ot.nr}">Zur Aufgabe</a>`;
  }

  // ------------------------------------------------------------------ Ansichten
  let active = null;
  function route() {
    if (active && active.destroy) active.destroy();
    active = null;
    const h = (location.hash || '#start').slice(1);
    let m;
    view.innerHTML = '';
    window.scrollTo(0, 0);
    if ((m = /^lektion-(\d+)$/.exec(h)) && LESSONS[Number(m[1]) - 1]) {
      const i = Number(m[1]) - 1, L = LESSONS[i];
      active = JK.mountLesson(view, L, Object.assign({}, ctx, { prevHash: i > 0 ? '#lektion-' + i : null, nextHash: i < LESSONS.length - 1 ? '#lektion-' + (i + 2) : null }));
      persist();
    } else if (h === 'noten') active = viewGrades();
    else if (h === 'challenges') active = viewChallenges();
    else if ((m = /^challenge-(c\d+)$/.exec(h)) && CHAL.find(c => c.id === m[1])) active = viewChallenge(CHAL.find(c => c.id === m[1]));
    else if (h === 'spielplatz') active = viewPlayground();
    else active = viewHome();
    renderNav();
  }
  function refresh() { renderNav(); if (active && active.refresh) active.refresh(); else if (!active || !active.player) route(); }

  // Startseite
  function viewHome() {
    const tasks = allTasks();
    const doneT = tasks.filter(x => subOf(x.task.id)).length, doneC = CHAL.filter(c => subOf(c.id)).length;
    const avg = avgOf(tasks.map(x => x.task.id).concat(CHAL.map(c => c.id)));
    const next = LESSONS.find(L => lessonProgress(L) < 1) || LESSONS[LESSONS.length - 1];
    const nextLs = S.lessons[next.id];
    view.innerHTML = `
      <header class="hero home">
        <div>
          <div class="kick">Java-Kurs · ${LESSONS.length} von ${C.plan.length} Lektionen verfügbar</div>
          <h1>Java lernen – Schritt für Schritt</h1>
          <p class="lead">Animierte Lektionen ohne Stimme, Java direkt im Browser und echte Aufgaben mit Noten von 1 bis 5. Ist eine Aufgabe offen, sind alle Videos gesperrt, bis du abgibst.</p>
          <div class="row"><a class="btn primary" href="#lektion-${next.nr}">${nextLs && nextLs.t > 1 ? `Weitermachen: Lektion ${next.nr} (bei ${fmtTime(nextLs.t)})` : `Starten: Lektion ${next.nr}`} →</a><a class="btn ghost" href="#challenges">Challenges</a></div>
        </div>
        <div class="stats">
          <div class="stat"><b>${LESSONS.filter(L => lessonProgress(L) >= 1).length}/${LESSONS.length}</b><span>Lektionen fertig</span></div>
          <div class="stat"><b>${doneT}/${tasks.length}</b><span>Aufgaben abgegeben</span></div>
          <div class="stat"><b>${doneC}/${CHAL.length}</b><span>Challenges gelöst</span></div>
          <div class="stat accent"><b>${fmtAvg(avg)}</b><span>Notenschnitt</span></div>
        </div>
      </header>
      <section class="path"><h2>Dein Lernpfad</h2>
        ${LESSONS.map(L => {
          const p = lessonProgress(L), ts = JK.buildTimeline(L).steps.filter(s => s.task).map(s => s.task);
          return `<a class="lesson" href="#lektion-${L.nr}"><div class="num ${p >= 1 ? 'ok' : ''}">${p >= 1 ? '✓' : L.nr}</div>
            <div><h3>${md(L.title)}</h3><p>${md(L.sub)}</p>
              <div class="bar" aria-label="Fortschritt ${Math.round(p * 100)} %"><i style="width:${Math.round(p * 100)}%"></i></div>
              <div class="tags">${ts.map(t => { const s = subOf(t.id); return `<span class="tag ${s ? 'g' + s.result.note : ''}">${esc(t.title)}: ${s ? s.result.note : 'offen'}</span>`; }).join('')}</div></div>
            <span class="go">${p >= 1 ? 'Wiederholen' : p > 0 ? 'Weiter' : 'Starten'} →</span></a>`;
        }).join('')}
        <a class="lesson chal" href="#challenges"><div class="num">★</div><div><h3>Transfer-Challenges</h3><p>${CHAL.length} Aufgaben, die so nie im Video vorkamen – lösbar mit dem, was du kannst.</p></div><span class="go">Los →</span></a>
        ${C.plan.slice(LESSONS.length).map(p => `<div class="lesson soon" aria-disabled="true"><div class="num">${p.nr}</div><div><h3>${esc(p.title)}</h3><p>${esc(p.what)}</p></div><span class="go muted">kommt noch</span></div>`).join('')}
      </section>
      <section class="goal">
        <h2>Das Ziel des Kurses</h2>
        <p>${md(C.goal)}</p>
        <div class="goalgrid">${C.canDo.map(x => `<div class="gcard"><b>${esc(x.h)}</b><span>${md(x.p)}</span></div>`).join('')}</div>
      </section>
      <section class="how"><h2>So läuft eine Lektion</h2>
        <ol>
          <li><span class="step">Schritt 1</span><b>Video ansehen</b><span>Code tippt sich selbst, Erklärtexte, Schaubilder. Pausieren und Tempo wählen geht jederzeit.</span></li>
          <li><span class="step">Schritt 2</span><b>Kurz-Checks</b><span>Zwischendurch kleine Quizfragen – nicht benotet, nur zum Merken.</span></li>
          <li><span class="step">Schritt 3</span><b>Aufgabe lösen</b><span>Alle Videos sperren sich. Du programmierst, testest mit „Ausführen“ und gibst ab.</span></li>
          <li><span class="step">Schritt 4</span><b>Note bekommen</b><span>Claude bewertet nach österreichischem System (1–5) mit Lob und Tipps.</span></li>
        </ol>
        <p class="muted small">Notengrenzen: ab 90 Punkten 1 · ab 78 → 2 · ab 64 → 3 · ab 50 → 4 · darunter 5. <span class="store-note">${esc(store.note)}</span></p>
      </section>`;
    return {};
  }

  // Notenbuch
  function viewGrades() {
    const rows = allTasks().map(x => ({ id: x.task.id, task: x.task, where: `Lektion ${x.lesson.nr}`, href: '#lektion-' + x.lesson.nr })).concat(CHAL.map(c => ({ id: c.id, task: c, where: 'Challenge', href: '#challenge-' + c.id })));
    const avgL = avgOf(rows.filter(r => r.where !== 'Challenge').map(r => r.id)), avgC = avgOf(CHAL.map(c => c.id)), avgAll = avgOf(rows.map(r => r.id));
    const locked = !!S.openTask;
    view.innerHTML = `
      <header class="lhead"><h1>Notenbuch</h1><p class="lead">Alle Abgaben aus Lektionen und Challenges an einem Ort. <span class="store-note">${esc(store.note)}</span></p></header>
      <div class="stats wide">
        <div class="stat accent"><b>${fmtAvg(avgAll)}</b><span>Gesamtschnitt</span></div>
        <div class="stat"><b>${fmtAvg(avgL)}</b><span>Schnitt Lektionen</span></div>
        <div class="stat"><b>${fmtAvg(avgC)}</b><span>Schnitt Challenges</span></div>
        <div class="stat"><b>${rows.filter(r => subOf(r.id)).length}/${rows.length}</b><span>abgegeben</span></div>
      </div>
      <div class="gbook">${rows.map(r => {
        const s = subOf(r.id);
        return `<details class="grow-row ${s ? 'g' + s.result.note : 'open'}" ${s ? '' : 'data-empty'}><summary><span class="gr-num">${s ? s.result.note : '–'}</span><span class="gtitle"><b>${md(r.task.title)}</b><span class="muted">${r.where}${s ? ' · ' + GRADE_WORD[s.result.note] + ' · ' + s.result.punkte + ' Punkte · ' + new Date(s.at).toLocaleDateString('de-AT') : ' · noch nicht abgegeben'}</span></span><a class="btn ghost small" href="${r.href}">${s ? 'Ansehen' : 'Zur Aufgabe'}</a></summary>
          ${s ? `<div class="gdetail">${JK.resultHTML(r.task, s, { hideSolution: locked })}${locked ? '' : `<h4>Deine Abgabe</h4><pre class="vcode">${JK.util.hlJava(s.code)}</pre>`}</div>` : ''}</details>`;
      }).join('')}</div>`;
    $$('details[data-empty] summary', view).forEach(sm => sm.addEventListener('click', e => { if (!e.target.closest('a')) e.preventDefault(); }));
    return { refresh: () => route() };
  }

  // Challenges
  function viewChallenges() {
    view.innerHTML = `
      <header class="lhead"><div class="crumbs"><span>Transfer-Challenges</span></div><h1>Kannst du’s auch anders?</h1>
        <p class="lead">Diese Aufgaben kamen so in keinem Video vor. Du hast aber alle Werkzeuge dafür – du musst sie nur neu kombinieren. Wenn du feststeckst, sagt dir jede Challenge, wo du nachschauen kannst.</p></header>
      <div class="chal-list">${CHAL.map(c => { const s = subOf(c.id); return `<a class="chal-card" href="#challenge-${c.id}"><div class="chal-top"><span class="lvl">${esc(c.level)}</span>${s ? `<span class="gpill g${s.result.note}">Note ${s.result.note}</span>` : ''}</div><h3>${md(c.title)}</h3><p>${md(c.teaser)}</p><div class="tags">${c.uses.map(u => `<span class="tag">${esc(u)}</span>`).join('')}</div></a>`; }).join('')}</div>`;
    return { refresh: () => route() };
  }
  function viewChallenge(c) {
    const i = CHAL.indexOf(c);
    view.innerHTML = `<div class="crumbs"><a href="#challenges">← Alle Challenges</a><span>Challenge ${i + 1} von ${CHAL.length}</span></div><section id="task" class="task"></section>
      <nav class="lnav">${i > 0 ? `<a class="btn ghost" href="#challenge-${CHAL[i - 1].id}">← ${esc(CHAL[i - 1].title)}</a>` : '<span></span>'}${i < CHAL.length - 1 ? `<a class="btn ghost" href="#challenge-${CHAL[i + 1].id}">${esc(CHAL[i + 1].title)} →</a>` : '<a class="btn ghost" href="#noten">Zum Notenbuch →</a>'}</nav>`;
    const panel = JK.taskPanel($('#task', view), c, ctx, {
      kicker: `Transfer-Challenge ${i + 1} · ${c.level}`,
      note: 'Kein Video, keine Sperre: Hier zeigst du, dass du das Gelernte neu kombinieren kannst. Auch diese Aufgabe wird benotet und landet im Notenbuch.',
      where: 'Transfer-Challenge nach Lektion 1–5 (Aufgabe so nie gezeigt, nur mit bekannten Mitteln lösbar)',
      continueLabel: i < CHAL.length - 1 ? 'Nächste Challenge →' : 'Zum Notenbuch →',
      onSubmitted: () => renderNav(),
      onContinue: () => ctx.navigate(i < CHAL.length - 1 ? '#challenge-' + CHAL[i + 1].id : '#noten'),
    });
    return { destroy: () => panel.destroy(), refresh: () => {} };
  }

  // Spielplatz
  function viewPlayground() {
    view.innerHTML = `<header class="lhead"><h1>Spielplatz</h1><p class="lead">Hier kannst du jederzeit Java ausprobieren – auch während eine Aufgabe offen ist. Dein Code bleibt in diesem Browser gespeichert.</p></header>
      <section class="card playground"><div id="pg-ed"></div><div class="task-btns"><button id="pg-run" class="btn">▶ Ausführen</button><button id="pg-stop" class="btn ghost" disabled>■ Stopp</button></div>
      <div class="task-con"><div class="pane-head">Konsole</div><div id="pg-con" class="con-live" role="log"><div class="cl"><span class="k-meta">Drück ▶ Ausführen.</span></div></div></div></section>`;
    let saved = C.playground;
    try { saved = localStorage.getItem('javakurs:playground') || saved; } catch (e) { /* egal */ }
    const ed = JK.makeEditor($('#pg-ed'), saved, v => { try { localStorage.setItem('javakurs:playground', v); } catch (e) { /* egal */ } });
    const runner = JK.makeRunner($('#pg-con'), () => ed.get(), { onState: on => { $('#pg-run').disabled = on; $('#pg-stop').disabled = !on; } });
    $('#pg-run').onclick = () => runner.start();
    $('#pg-stop').onclick = () => runner.stop();
    return { destroy: () => runner.stop() };
  }

  window.addEventListener('hashchange', route);
  route();
  initStore();
  JK.course = { S, route, persist };
})();
